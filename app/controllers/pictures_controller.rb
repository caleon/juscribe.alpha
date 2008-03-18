class PicturesController < ApplicationController
  use_shared_options
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    return unless get_depictable(:message => "Unable to find the object specified. Please check the address.") && authorize(@depictable)
    find_opts = @depictable.pictures.find(:all, find_opts)
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup(:permission)
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_depictable(:message => "Unable to find the object to depict. Please check the address.") && authorize(@depictable)
    # Does authorize need to be here? What happens when friend wants to upload
    # a picture of you?
    @picture = @depictable.pictures.new
  end
  
  def create
    return if @picture = create_uploaded_picture_for(get_viewer, :save => true, :respond => true)
    respond_to do |format|
      format.html { render :action => 'new' }
      format.js { render :action => 'create_error' }
    end
  end
  
  def edit
    return unless setup(:permission)
    @use_kropper = true
    respond_to do |format|
      format.html
      format.js
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
  
  def destroy
    return unless setup(:permission) && authorize(@picture, :editable => true)
    @picture.nullif!(get_viewer)
    msg = "You have deleted a picture on #{@depictable.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to depictable_url_for(@depictable) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup
    return unless get_depictable
    @picture = @depictable.pictures.find(params[:id], :include => includes)
    authorize(@picture)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Picture could not be found. Please check the address."
    display_error(error_opts)
    false
  end
  
  def get_depictable(opts={})
    return false if (possible_depictable_keys = params.keys.select{|key| key.match(/_id$/) }).empty?
    depictable_id_key = %w( event entry song item project article gallery blog playlist list group user ).map{|kls| "#{kls}_id" }.detect do |key|
      possible_depictable_keys.include?(key)
    end
    depictable_class = depictable_id_key.gsub(/_id$$/, '').classify.constantize
    if depictable_class == Article
      @depictable = Article.primary_find(params, :for_association=> true, :include => :permission)
    else
      @depictable = depictable_class.primary_find(params[depictable_id_key], :include => :permission)
    end
    raise ActiveRecord::RecordNotFound if @depictable.nil?
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{depictable_class} could not be found.")
    false
  end
  
  def picture_url_for(picture)
    prefix = picture.depictable_type.underscore
    instance_eval %{ #{prefix}_picture_url(picture.to_polypath) }
  end
  
  def depictable_url_for(depictable)
    prefix = depictable.class.to_s.underscore
    instance_eval %{ #{prefix}_url(depictable.to_path) }
  end
  
end
