class PicturesController < ApplicationController
  use_shared_options
  
  def show
    super(:include => :permission)
  end
  
  def edit
    return unless setup(:permission)
    @use_kropper = true
  end
  
  def create
    return if @picture = create_uploaded_picture_for(get_viewer, :save => true, :respond => true)
    respond_to do |format|
      format.html { render :action => 'new' }
      format.js { render :action => 'create_error' }
    end
  end
  
  def update
    return unless setup(:permission)
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
  
  private
  def setup
    
  end
  
  def get_commentable(opts={})
    return false if (possible_commentable_keys = params.keys.select{|key| key.match(/_id$/) }).empty?
    commentable_id_key = %w( picture article song project item group event entry list playlist user ).map{|kls| "#{kls}_id"}.detect do |key|
      possible_commentable_keys.include?(key)
    end
    commentable_class = commentable_id_key.gsub(/_id$/, '').classify.constantize
    if commentable_class == Article
      @commentable = Article.primary_find(params, :for_association => true, :include => :permission)
    else
      @commentable = commentable_class.primary_find(params[commentable_id_key], :include => :permission)
    end
    raise ActiveRecord::RecordNotFound if @commentable.nil?
    @commentable
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{commentable_class} could not be found.")
    false
  end
  
  def get_gallery
    return false unless params[:gallery_id]
    if params[:user_id]
      get_user
      @gallery = @user.galleries.find(params[:gallery_id])
    else
      
    end
  end
  
end
