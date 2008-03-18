class PicturesController < ApplicationController
  use_shared_options
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    return unless get_depictable(:message => "Unable to find the object specified. Please check the address.") && authorize(@depictable)
    find_opts = get_find_opts(:order => 'pictures.id DESC')
    @pictures = @depictable.pictures.find(:all, find_opts)
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
    @picture = @depictable.pictures.new
  end
  
  def create
    return unless get_depictable(:message => "Unable to find_the_object to depict. Please check the address.") && authorize(@depictable)
    @picture = create_uploaded_picture_for(@depictable, :save => true, :respond => true)
    return if @picture.errors.empty?
    respond_to do |format|
      format.html { render :action => 'new' }
      format.js { render :action => 'create_error' }
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@picture, :editable => true)
    @use_kropper = true
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@picture, :editable => true)
    @use_kropper = true
    if params[:picture].delete(:crop_cancel) == "true"
      msg = "Image editing canceled."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to picture_url_for(@picture) }
        format.js { flash.now[:notice] = msg; render :action => 'update_canceled' }
      end
    else
      begin
        if params[:picture].delete(:do_crop) == "Crop"
          @picture.send(:set_crop_params, params[:picture_crop])
          @picture.crop!
        else
          @picture.update_attributes!(params[:picture])
        end
        msg = "You have successfully edited your image."
        respond_to do |format|
          format.html { flash[:notice] = msg; redirect_to picture_url_for(@picture, 'edit') }
          format.js { flash.now[:notice] = msg }
        end
      rescue Picture::InvalidCropRect, ActiveRecord::RecordInvalid => e
        flash.now[:warning] = "There was an error editing your picture: #{e.message}"
        respond_to do |format|
          format.html { render :action => 'edit' }
          format.js { render :action => 'update_error' }
        end
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@picture, :editable => true)
    @picture.nullify!(get_viewer)
    msg = "You have deleted a picture on #{@depictable.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to depictable_url_for(@depictable) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    return unless get_depictable
    @picture = @depictable.pictures.find(params[:id], :include => includes)
    authorize(@picture)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Picture could not be found. Please check the address."
    display_error(error_opts)
    false
  end
  
  def get_depictable(opts={})
    unless request.path.match(/\/([_a-zA-Z]+)\/([^\/]+)\/pictures/)
      display_error(:message => "Unable to process the request. Please check the address.")
      return false
    end
    begin      
      klass, id = $1.singularize.classify.constantize, $2
      @depictable = klass.primary_find(id, :include => :permission)
    rescue NameError
      klass, id = Article, nil
      @depictable = Article.primary_find(params, :for_association => true, :include => :permission)
    end
    raise ActiveRecord::RecordNotFound if @depictable.nil?
    @depictable
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{klass.to_s.humanize} could not be found. Please check the address.")
  end
end
