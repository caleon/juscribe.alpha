class PicturesController < ApplicationController
  
  def create
    return if @picture = create_uploaded_picture_for(@viewer, :save => true, :respond => true)
    respond_to do |format|
      format.html { render :action => 'new' }
      format.js { render :action => 'create_error' }
    end
  end
  
  def update
    return unless setup
    if params[:picture].delete(:crop_cancel) == "true"
      msg = "Image editing canceled."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @picture }
        format.js { flash.now[:notice] = msg; render :action => 'update_canceled'}
      end
    else
      begin
        @picture.attributes = params[:picture]
        @picture.crop!
        msg = "You have successfully edited your image."
        respond_to do |format|
          format.html { flash[:notice] = msg; redirect_to edit_picture_url(@picture) }
          format.js { flash.now[:notice] = msg }
        end
      rescue Picture::InvalidCropRect, ActiveRecord::RecordInvalid => e
        flash.now[:warning] = "There was an error editing your picture: #{e.message}"
        respond_to do |format|
          format.html { render :action => 'crop' }
          format.js { render :action => 'update_error' }
        end
      end
    end
  end
  
end
