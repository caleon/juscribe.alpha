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
        format.js
      end
    end
  end
  
  def create
    if get_taggable.nil? || !authorize(@taggable)
      display_error(:message => 'You are not authorized for that action.')
    else
      @page_title = "New Tag on #{@taggable.display_name}"
      @tag = @taggable.tag_with(params[:tag][:name], :user => get_viewer)
      if @tag.save
        msg = "You have tagged #{@taggable.display_name}."
        respond_to do |format|
          format.html { flash[:notice] = msg; redirect_to taggable_url_for(@taggable) }
          format.js { flash.now[:notice] = msg }
        end
      else
        flash.now[:warning] = "There was an error tagging #{@taggable.display_name}."
        respond_to do |format|
          format.html { trender :new }
          format.js { render :action => 'create_error' }
        end
      end
    end
  end
  
  # Don't think I need edit and update
  
  def destroy
    return unless setup && authorize(@taggable, :editable => true)
    @taggable.taggings.find_by_tag_id(@tag.id).nullify!(get_viewer)
    msg = "You have deleted a tag on #{@taggable.display_name}."
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
        @taggable = klass.primary_find(id, :include => :permission)
      rescue
        klass, id = Article, nil
        @taggable = Article.primary_find(params, :for_association => true, :include => :permission)
      end
    end
    @taggable
  end
end
