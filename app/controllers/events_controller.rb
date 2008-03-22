class EventsController < ApplicationController
  use_shared_options
  verify_login_on :new, :create, :edit, :update, :destroy, :begin_event, :end_event
  authorize_on :show, :edit, :update, :destroy, :begin_event, :end_event
  
  def index
    return unless get_user
    find_opts = get_find_opts(:order => 'id DESC')
    @events = Event.find(:all, find_opts.merge(:conditions => ["user_id = ?", @user.id]))
    @page_title = "#{@user.display_name}'s Events"
    @layoutable = @user
    respond_to do |format|
      format.html { render :template => Event.find(:first).layout_file(:index) if @user.layout }
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup(:permission)
    @page_title = @event.display_name
    @layoutable = @event
    respond_to do |format|
      format.html { render :template => @event.layout_file(:show) if @event.layout }
      format.js
      format.xml
    end
  end
  
  def new # TODO: extend ActiveRecord's association collection to be able to do user.events.accessible_by?
    return unless get_user
    redirect_to new_user_event_url(get_viewer) and return if @user != get_viewer
    @event = @user.events.new
    @layoutable = @event
    @page_title = "New Event"
    respond_to do |format|
      format.html { render :template => @event.layout_file(:new) if @event.layout }
      format.js
    end
  end
  
  def create
    return unless get_user
    # get_viewer should not be nil since verify_login_on handles filter.
    @event = get_viewer.events.new(params[:event])
    @page_title = "New Event"
    @layoutable = @event
    if @event.save
      create_uploaded_picture_for(@event, :save => true) if picture_uploaded?
      msg = "You have successfully created your event."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(@event.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your event."
      respond_to do |format|
        format.html do
          if @event.layout
            render :template => @event.layout_file(:new)
          else
            render :action => 'new'
          end
        end
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@event, :editable => true)
    @page_title = "#{@event.display_name} - Edit"
    @layoutable = @event
    respond_to do |format|
      format.html { render :template => @event.layout_file(:new) if @event.layout }
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@event, :editable => true)
    @page_title = "#{@event.display_name} - Edit"
    @layoutable = @event
    if @event.update_attributes(params[:event])
      create_uploaded_picture_for(@event, :save => true) if picture_uploaded?
      msg = "You have successfully updated #{@event.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(@event.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@event.display_name}."
      respond_to do |format|
        format.html do
          if @event.layout
            render :template => @event.layout_file(:edit)
          else
            render :action => 'edit'
          end
        end
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def begin_event
    return unless setup(:permission) && authorize(@event, :editable => true)
    @page_title = "#{@event.display_name} - Edit"
    @layoutable = @event
    if @event.begin!
      msg = "Your event #{@event.display_name} has officially begun!"
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(@event.user, @event) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error commencing your event #{@event.display_name}."
      respond_to do |format|
        format.html do
          if @event.layout
            render :template => @event.layout_file(:edit)
          else
            render :action => 'edit'
          end
        end
        format.js { render :action => 'begin_event_error' }
      end
    end
  end
  
  def end_event
    return unless setup(:permission) && authorize(@event, :editable => true)
    @page_title = "#{@event.display_name} - Edit"
    @layoutable = @event
    if @event.end!
      msg = "Your event #{@event.display_name} has officially ended!"
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(@event.user, @event) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error ending your event #{@event.display_name}."
      respond_to do |format|
        format.html do
          if @event.layout
            render :template => @event.layout_file(:edit)
          else
            render :action => 'edit'
          end
        end
        format.js { render :action => 'end_event_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@event, :editable => true)
    msg = "You have deleted #{@event.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to :back }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    return false unless get_user
    @event = @user.events.find(params[:id], :include => includes)
    authorize(@event)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Event entry could not be found. Please check the address."
    display_error(error_opts)
    false
  end
end
