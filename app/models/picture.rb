class Picture < ActiveRecord::Base
  acts_as_itemizable :scope => :gallery
  include PluginPackage
  
  belongs_to :user
  belongs_to :depictable, :polymorphic => true
  has_attachment  :content_type => :image,
                  :storage => (RAILS_ENV != 'production' ? :file_system : :s3),
                  :path_prefix => "public/images/uploads", # TODO: Setup shared directory.
                  :min_size => 100.bytes,
                  :max_size => 2048.kilobytes,
                  :resize_to => '800x800>', # Used by RMagick, so probably not needed.
                  :thumbnails => { :thumb => '100x100' },
                  :processor => 'ImageScience'
  
  validates_as_attachment
  # ...does the following:  validates_presence_of :size, :content_type, :filename
  #                         validate :attachment_attributes_valid?
  validates_presence_of :depictable_type, :depictable_id, :user_id
  # attr_protected :depictable_type, :depictable_id ????? Perhaps this needed so forms dont get hax0red.
  # Needs more validations for kropper
  
  DEFAULT_CROP = { :crop_left         =>  0,
                   :crop_top          =>  0,
                   :crop_width        =>  100,
                   :crop_height       =>  100,
                   :stencil_width     =>  100,
                   :stencil_height    =>  100,
                   :resize_to_stencil =>  false }
  
  class InvalidCropRect < StandardError; end
  class CropParams
    def initialize(attrs={}); @attrs = attrs; end
    def [](key); @attrs[key]; end
    def set(key, val); @attrs[key] = val; end
    def get(key); @attrs[key]; end
    def valid_with?(width, height)
      self[:crop_width] > 0 && self[:crop_height] > 0 && self[:crop_left] + self[:crop_width] > 0 &&
      self[:crop_top] + self[:crop_height] > 0 && self[:crop_left] < width && self[:crop_top] < height
    end
    def reveal
      [ self[:crop_left], self[:crop_top], self[:crop_left] +
        self[:crop_width], self[:crop_top] + self[:crop_height] ]
    end
  end
  
  # Make this method grab values from existing column values in DB table
  def crop_params; @crop_params ||= CropParams.new; end
  def set_crop_params(attrs); @crop_params = CropParams.new(attrs); end; private :set_crop_params
  [ :crop_left, :crop_top, :crop_width, :crop_height, :stencil_width, :stencil_height, :resize_to_stencil ].each do |key|
    class_eval %{ def #{key}=(val); crop_params.set(:#{key}, val.to_i); end; def #{key}; crop_params.get(:#{key}); end }
  end # :resize_to_stencil will have to be set to 1 or "1" to be true
  
  def file_path(size=nil) # TODO: symlink uploads directory in images to shared one.
    public_filename
  end
  
  def to_path
    if self.depictable.nil?
      { :id => self.to_param }
    else
      depictable_sym = "#{self.depictable_type.downcase}_id".intern
      { depictable_sym => self.depictable.to_param, :id => self.to_param }      
    end
  end
  
  # set_crop_params only for internal use. Use built-in attribute-setter
  # from controller, i.e. Picture.new(params) which will automatically
  # instantiate and set a CropParams object.
  def crop!(opts=nil); crop_with_image_science!(opts ? set_crop_params(opts) : crop_params); end
  
    
  #######
  private
  #######
  
  def crop_with_image_science!(par=crop_params)
    self.with_image do |img|
      raise InvalidCropRect unless par.valid_with?(img.width, img.height)
      self.temp_path = write_to_temp_file(filename)
      img.with_crop(*par.reveal) do |cropped_img|
        if par[:resize_to_stencil]
          cropped_img.resize(par[:stencil_width], par[:stencil_height]) do |crop_resized_img|
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
end
