class PicturesController < ApplicationController
  before_filter :verify_logged_in,
                :except => [ :index, :view ]
    
  def index
    @pictures = Picture.find(:all, :limit => 20, :order => 'id DESC')
  end

  def view
    show
    render :action => 'show'
  end
  
  def show
    return unless setup
  end
  
  def edit
    return unless setup
  end
  
  def update
    return unless setup
    if @picture.update_attributes(params[:picture])
      
    else
      
    end
  end
  
  def new
    @picture = @viewer.owned_pictures.new
  end
  
  def create
    save_uploaded_image_for(@viewer)
  end
  
  def destroy
    return unless setup
    @picture.update_attributes(:user_id => DB[:garbage_id],
                               :depictable_type => 'Deleted' +
                                                   @picture.depictable_type)
  end
  
  def prepare_crop
    return unless setup
  end
  
  def crop
    return unless setup
    # we got a post request, so first see if the cancel button was clicked
    if params[:crop_cancel] && params[:crop_cancel] == "true"
      # this means the cancel button was clicked. you might
      # want to implement a more-sophisticated cancel behavior
      # in your app -- for instance, if you store the previous
      # request in the session, you could redirect there instead
      # of to the app's root, as i'm doing here.
      flash[:notice] = "Cropping canceled."
      render :action => 'prepare_crop'
      return
    end
    # cancel was not clicked, so crop the image
    @picture.crop! params
    if @picture.save
      flash[:notice] = "Image cropped and saved successfully."
      redirect_to @picture
      return
    end
  rescue Picture::InvalidCropRect
    flash[:warning] = "Sorry, could not crop the image."
  end
  
  private
  def setup(includes=nil, opts={})
    if params[:id] && @picture = Picture.find(params[:id], :include => includes)
      true
    else
      display_error(opts)
      false
    end
  end
end
