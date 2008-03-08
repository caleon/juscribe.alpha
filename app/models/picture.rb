class Picture < ActiveRecord::Base
  acts_as_itemizable :gallery
  include PluginPackage
  
  class InvalidCropRect < StandardError; end

  belongs_to :user
  belongs_to :depictable, :polymorphic => true
  #has_attachment  :content_type => :image,
  #                :storage => :file_system,
  #                :path_prefix => "public/images/uploads", # Setup shared directory
  #                :min_size => 100.bytes,
  #                :max_size => 2048.kilobytes,
  #                :resize_to => '800x800>',
  #                :thumbnails => { :thumb => '100x100' },
  #                :processor => 'ImageScience'
  #
  #validates_as_attachment
  validates_presence_of :depictable_type, :depictable_id, :user_id
  # Needs more validations
    
  def file_path(size=nil) # TODO: symlink uploads directory in images to shared one.
    "uploads/" + self.depictable_type + '/' + self.id.to_s + ".jpg"
  end
  
  def crop!(opts={})
    options = { :crop_left         =>  0,
                :crop_top          =>  0,
                :crop_width        =>  100,
                :crop_height       =>  100,
                :stencil_width     =>  100,
                :stencil_height    =>  100,
                :resize_to_stencil =>  false}.merge(opts)
    options[:resize_to_stencil] =
          { false   =>  false,  'false' =>  false,
            true    =>  true,   'true'  =>  true }[options[:resize_to_stencil]]
    options.each {|k, v| options[k] = v.to_i if v.is_a?(String) }
    
    crop_with_image_science!(crop_l, crop_t, crop_w, crop_h,
                             stencil_w, stencil_h, resize_to_stencil)
  end
  
  #######
  private
  #######
  
  def crop_with_image_science!(crop_l, crop_t, crop_w, crop_h, stencil_w, stencil_h, resize_to_stencil)
    self.with_image do |img|
      if (crop_w <= 0) || (crop_h <= 0) || (crop_l + crop_w <= 0) || (crop_t + crop_h <= 0) || (crop_l >= img.width) || (crop_t >= img.height)
        # the passed cropping parameters are outside the boundaries of the image, so raise
        raise InvalidCropRect
      end
      self.temp_path = write_to_temp_file(filename)
      img.with_crop(crop_l, crop_t, crop_l + crop_w, crop_t + crop_h ) do |cropped_img|
        if resize_to_stencil
          cropped_img.resize(stencil_w, stencil_h) do |cropped_resized_img|
            cropped_resized_img.save temp_path
            callback_with_args :after_resize, cropped_resized_img
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
