class Picture < ActiveRecord::Base
  include_custom_plugins  
  
  belongs_to :user
  belongs_to :depictable, :polymorphic => true, :inherits_layout => true
  acts_as_list :scope => 'depictable_id = #{depictable_id} AND depictable_type = \'#{depictable_type}\''
  has_attachment  :content_type => :image,
                  #:storage => :file_system, #(RAILS_ENV != 'production' ? :file_system : :s3),
                  :storage => (RAILS_ENV != 'production' ? :file_system : :s3),
                  #:path_prefix => "public/images/uploads", # TODO: Setup shared directory.
                  :path_prefix => (RAILS_ENV != 'production' ? "public/images/uploads" : "uploads/pictures"),
                  :min_size => 100.bytes,
                  :max_size => 2048.kilobytes,
                  #:resize_to => '800x800>', # Used by RMagick, so probably not needed.
                  :thumbnails => { :thumb => '100x100', :feature => '300x400' },
                  :processor => 'ImageScience'
  
  validates_as_attachment
  # ...does the following:  validates_presence_of :size, :content_type, :filename
  #                         validate :attachment_attributes_valid?
  validates_presence_of :depictable_type, :depictable_id, :user_id
  validates_length_of :name, :in => 3..50
  validates_length_of :caption, :in => 3..200, :allow_blank => true
  validates_with_regexp :name, :caption
  attr_protected :depictable_type, :depictable_id
  # Needs more validations for kropper
  alias_attribute :content, :caption
    
  DEFAULT_CROP = { :crop_left         =>  0,
                   :crop_top          =>  0,
                   :crop_width        =>  100,
                   :crop_height       =>  100,
                   :stencil_width     =>  100,
                   :stencil_height    =>  100,
                   :resize_to_stencil =>  false }
 
  def display_name
    "Picture: " + (self.caption.blank? ? "for #{self.depictable.display_name}" : self.caption.to_s)
  end
 
  def name
    self[:name] || "Untitled"
  end
  
  def caption
    if self.thumbnail.blank?
      self[:caption].blank? ? nil : self[:caption]
    else
      self[:caption].blank? ? self.parent.caption : self[:caption]
    end
  end
  
  def source
    if self.thumbnail.blank?
      self[:source].blank? ? nil : self[:source]
    else
      self[:source].blank? ? self.parent.source : self[:source]
    end
  end
  
  def to_path(for_associated=false)
    { :"#{for_associated ? 'picture_id' : 'id'}" => self.to_param }.merge(self.depictable.nil? ? {} : self.depictable.to_path(true))
  end
  
  def path_name_prefix
    [ self.depictable.path_name_prefix, 'picture' ].join('_')
  end
  
  def accessible_by?(user)
    self.depictable.accessible_by?(user) && super
  end
  
  def editable_by?(user)
    self.depictable.editable_by?(user) || super
  end
  
  def other_pictures
    self.depictable.pictures - [self]
  end
  
  def other_picture_thumbs
    other_pictures.map{|pic| pic.thumbnails.find_by_thumbnail('thumb') }
  end
  
  def feature?; self.thumbnail == 'feature'; end
  def thumb?; self.thumbnail == 'thumb'; end
  def original?; self.thumbnail.blank?; end
  
  def original_filename
    filename.gsub(/(.+)(\.[a-z]+)$/, '\1_original\2')
  end
  
  def full_original_filename
    full_filename.gsub(/(.+)(\.[a-z]+)$/, '\1_original\2')
  end
  
  def public_original_filename
    public_filename.gsub(/(.+)(\.[a-z]+)$/, '\1_original\2')
  end
      
  # Overwriting for depictable_type
  def full_filename(thumbnail = nil)
    if attachment_options[:storage] != :s3
      file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
      File.join(RAILS_ROOT, file_system_path, self.depictable_type.underscore, *partitioned_path(thumbnail_name_for(thumbnail)))
    else
      super
    end
  end
  
  def current_data_with_original(version=nil)
    AWS::S3::S3Object.value((version == :original ? full_original_filename : full_filename), bucket_name)
  end
  alias_method_chain :current_data, :original
  
  ### IMAGE PROCESSING METHODS
  
  # Overwriting for depictable_id, depictable_type, user_id
  def create_or_update_thumbnail(temp_file, file_name_suffix, *size)
    thumbnailable? || raise(ThumbnailError.new("Can't create a thumbnail if the content type is not an image or there is no parent_id column"))
    returning find_or_initialize_thumbnail(file_name_suffix) do |thumb|
      thumb.attributes = {
        :content_type             => content_type, 
        :filename                 => thumbnail_name_for(file_name_suffix), 
        :temp_path                => temp_file,
        :thumbnail_resize_options => size,
        :depictable               => self.depictable,
        :user                     => self.user
      }
      callback_with_args :before_thumbnail_saved, thumb
      thumb.save!
    end
  end
  
  class InvalidCropRect < StandardError; end
  class CropParams
    def initialize(attrs={}); @attrs = attrs; end
    def [](key); @attrs[key]; end
    def set(key, val); @attrs[key] = val; end
    def get(key); @attrs[key]; end
    def valid_with?(width, height)
      self[:crop_width].to_i > 0 && self[:crop_height].to_i > 0 && self[:crop_left].to_i + self[:crop_width].to_i > 0 &&
      self[:crop_top].to_i + self[:crop_height].to_i > 0 && self[:crop_left].to_i < width && self[:crop_top].to_i < height
    end
    def reveal
      [ self[:crop_left].to_i, self[:crop_top].to_i, self[:crop_left].to_i +
        self[:crop_width].to_i, self[:crop_top].to_i + self[:crop_height].to_i ]
    end
  end
  
  # Make this method grab values from existing column values in DB table
  def crop_params; @crop_params ||= CropParams.new; end
  def set_crop_params(attrs); @crop_params = CropParams.new(attrs); end
  private :set_crop_params
  [ :crop_left, :crop_top, :crop_width, :crop_height, :stencil_width, :stencil_height, :resize_to_stencil ].each do |key|
    class_eval %{ def #{key}=(val); crop_params.set(:#{key}, val.to_i); end; def #{key}; crop_params.get(:#{key}); end }
  end # :resize_to_stencil will have to be set to 1 or "1" to be true
  
  
  # set_crop_params only for internal use. Use built-in attribute-setter
  # from controller, i.e. Picture.new(params) which will automatically
  # instantiate and set a CropParams object.
  def crop!(opts=nil); crop_with_image_science!(opts ? set_crop_params(opts) : crop_params); end
  
    
  #######
  protected
  #######
  # overriding s3_backend AND file_system_backend method
  def save_to_storage
    if save_attachment?
      orig_name = full_filename.gsub(/(.+)(\.[a-z]+)$/, '\1_original\2')
      if attachment_options[:storage] == :s3
        AWS::S3::S3Object.store(
          full_filename,
          (temp_path ? File.open(temp_path) : temp_data),
          bucket_name,
          :content_type => content_type,
          :access => attachment_options[:s3_access]
        )
        AWS::S3::S3Object.store(
          orig_name,
          (temp_path ? File.open(temp_path) : temp_data),
          bucket_name,
          :content_type => content_type,
          :access => attachment_options[:s3_access]
        ) if !self.thumbnail? && !AWS::S3::S3Object.exists?(orig_name, bucket_name)
      else
        # TODO: This overwrites the file if it exists, maybe have an allow_overwrite option?
        FileUtils.mkdir_p(File.dirname(full_filename))
        File.cp(temp_path, full_filename)
        File.chmod(attachment_options[:chmod] || 0644, full_filename)
        if !self.thumbnail? && !File.exists?(orig_name)
          File.cp(temp_path, orig_name)
          File.chmod(attachment_options[:chmod] || 0644, orig_name)
        end
      end
    end
    @old_filename = nil
    true
  end
  
  #######
  private
  #######
  
  def crop_with_image_science!(par=crop_params)
    self.temp_data = self.current_data(:original) if attachment_options[:storage] == :s3
    self.with_image do |img|
      raise InvalidCropRect unless par.valid_with?(img.width, img.height)
      # Apparently if this next line exists outside the block, i get the imagescience error about
      # terminating when it threw instance of 'int':
      # "terminate called after throwing an instance of 'int'"
      self.temp_path = write_to_temp_file(original_filename) if attachment_options[:storage] != :s3
      img.with_crop(*par.reveal) do |cropped_img|
        if par[:resize_to_stencil].to_i == 1
          cropped_img.resize(par[:stencil_width].to_i, par[:stencil_height].to_i) do |crop_resized_img|
            crop_resized_img.save temp_path
            callback_with_args :after_resize, crop_resized_img
          end
        else
          cropped_img.save temp_path
          callback_with_args :after_resize, cropped_img
        end
      end
    end
    save!
  end
  
  # don't need, since we are overriding #save_to_storage method.
  # def save_original_copy
  #   if self.thumbnail.nil?
  #     FileUtils.mkdir_p(File.dirname(full_filename))
  #     orig_name = full_filename.gsub(/(.+)(\.[a-z]+)$/, '\1_original\2')
  #     File.cp(temp_path, orig_name)
  #     File.chmod(attachment_options[:chmod] || 0644, orig_name)
  #   end
  # end
  #
  # don't need since overriding #save_to_storage method
  #after_create :save_original_copy
  
end
