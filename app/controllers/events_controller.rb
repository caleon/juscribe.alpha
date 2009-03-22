class EventsController < ApplicationController
  use_shared_options :collection_owner => :user
  verify_login_on :new, :create, :edit, :update, :destroy, :begin_event, :end_event
  authorize_on :show, :edit, :update, :destroy, :begin_event, :end_event
  
  def index
    return unless get_user
    find_opts = get_find_opts(:order => 'id DESC')
    @events = @user.events.find(:all, find_opts)
    @page_title = "#{@user.display_name}'s Events"
    respond_to do |format|
      format.html { trender }
      format.js
      format.rss { render :layout => false }
    end
  end
  
  def show
    return unless setup(:permission)
    @page_title = @event.display_name
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def new # TODO: extend ActiveRecord's association collection to be able to do user.events.accessible_by?
    return unless get_user
    redirect_to new_user_event_url(get_viewer) and return if @user != get_viewer
    @event = @user.events.new
    @page_title = "New Event"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def create
    return unless get_user
    # get_viewer should not be nil since verify_login_on handles filter.
    @event = get_viewer.events.new(params[:event])
    @page_title = "New Event"
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
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@event, :editable => true)
    @page_title = "#{@event.display_name} - Edit"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@event, :editable => true)
    @page_title = "#{@event.display_name} - Edit"
    if @event.update_attributes(params[:event])
      create_uploaded_picture_for(@event, :save => true) if picture_uploaded?
      msg = "You have successfully updated #{flash_name_for(@event)}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(@event.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{flash_name_for(@event)}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def begin_event
    return unless setup(:permission) && authorize(@event, :editable => true)
    @page_title = "#{@event.display_name} - Edit"
    if @event.begin!
      msg = "Your event #{flash_name_for(@event)} has officially begun!"
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(@event.user, @event) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error commencing your event #{flash_name_for(@event)}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'begin_event_error' }
      end
    end
  end
  
  def end_event
    return unless setup(:permission) && authorize(@event, :editable => true)
    @page_title = "#{@event.display_name} - Edit"
    if @event.end!
      msg = "Your event #{flash_name_for(@event)} has officially ended!"
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(@event.user, @event) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error ending your event #{flash_name_for(@event)}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'end_event_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@event, :editable => true)
    msg = "You have deleted #{flash_name_for(@event)}."
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
