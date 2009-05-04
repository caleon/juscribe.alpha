class TagsController < ApplicationController
  use_shared_options :collection_owner => :taggable
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    if @taggable && !authorize(@taggable)
      return display_error(:message => 'You are not authorized for that action.')
    end
    find_opts = get_find_opts(:order => :name)
    @tags = @taggable ? @taggable.tags.find(:all, find_opts) : Tag.find(:all, find_opts)
    @page_title = "Tags for #{@taggable ? @taggable.display_name : 'Site'}"
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup
    @page_title = @tag.display_name
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def new
    if get_taggable.nil? || !authorize(@taggable)
      display_error(:message => 'You are not authorized for that action.')
    else
      @tagging = @taggable.taggings.new
      @page_title = "New Tag on #{@taggable.display_name}"
      respond_to do |format|
        format.html { trender }
        format.js { render :partial => 'new', :content_type => :html }
      end
    end
  end
  
  def create
    if get_taggable.nil? || !authorize(@taggable)
      display_error(:message => 'You are not authorized for that action.')
    else
      @page_title = "New Tag on #{@taggable.display_name}"
      if @taggable.tag_with(params[:tagging][:name], :user => get_viewer)
        msg = "You have tagged #{flash_name_for(@taggable)}."
        respond_to do |format|
          format.js { flash.now[:notice] = msg }
          format.html { flash[:notice] = msg; redirect_to taggable_url_for(@taggable) }
        end
      else
        raise 
      end
    end
  rescue
    flash.now[:warning] = "There was an error tagging #{flash_name_for(@taggable)}."
    respond_to do |format|
      format.js { render :action => 'create_error' }
      format.html { trender :new }
    end    
  end
  
  # Don't think I need edit and update
  
  def destroy
    return unless setup && authorize(@taggable, :editable => true)
    @taggable.taggings.find_by_tag_id(@tag.id).nullify!(get_viewer)
    msg = "You have deleted a tag on #{flash_name_for(@taggable)}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to taggable_url_for(@taggable) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    get_taggable
    @tag = Tag.primary_find(params[:id], :include => includes)
    # authorize(@tag)
    # Need to authorize @taggable i think
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Tag could not be found. Please check the address."
    display_error(error_opts)
    false
  end
  
  def get_taggable(opts={})
    unless request.path.match(/\/([-_a-zA-Z0-9]+)\/([^\/]+)\/tags/)
      @taggable = nil
    else
      begin klass_name = $1.size == 1 ? {'u' => 'users', 'g' => 'groups'}[$1] : $1
        klass, id = klass_name.singularize.classify.constantize, $2
        @taggable = klass.primary_find(id, :include => :permission_rule)
      rescue
        klass, id = Article, nil
        @taggable = Article.primary_find(params, :for_association => true, :include => :permission_rule)
      end
    end
    @taggable
  end
end
