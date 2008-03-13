class EventsController < ApplicationController
  use_shared_options
  verify_login_on :new, :create, :edit, :update, :destroy, :begin_event, :end_event
  authorize_on :show, :edit, :update, :destroy, :begin_event, :end_event
  
  def index
    find_opts = get_find_opts(:order => 'id DESC')
    if @user = User.primary_find(params[:user_id])
      @events = Event.find(:all, find_opts.merge(:conditions => ["user_id = ?", @user.id]))
    else
      display_error(:message => "That User entry could not be found. Please check the address.")
    end
  end
  
  def new # TODO: extend ActiveRecord's association collection to be able to do user.events.accessible_by?
    if @user = User.find_by_nick(params[:user_id])
      if @user == get_viewer
        @event = Event.new
      else 
        redirect_to new_user_event_url(get_viewer) and return
      end
    else
      display_error(:message => "That User entry could not be found. Please check the address.")
    end
  end
  
  def create
    @event = Event.new(params[:event].merge(:user => get_viewer))
    if @event.save
      create_uploaded_picture_for(@event, :save => true) if picture_uploaded?
      msg = "You have successfully created your event."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(get_viewer, @event) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your event."
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@event, :editable => true)
    @page_title = "#{@event.display_name} - Edit"
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def update
    return unless (setup && authorize(@event, :editable => true))
    if @event.update_attributes(params[:event])
      msg = "You have successfully updated #{@event.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(@event.user, @event) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@event.display_name}."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def begin_event
    return unless setup && authorize(@event, :editable => true)
    if @event.begin!
      msg = "Your event #{@event.display_name} has officially begun!"
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(@event.user, @event) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error commencing your event #{@event.display_name}."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'begin_event_error' }
      end
    end
  end
  
  def end_event
    return unless setup && authorize(@event, :editable => true)
    if @event.end!
      msg = "Your event #{@event.display_name} has officially ended!"
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_event_url(@event.user, @event) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error ending your event #{@event.display_name}."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'end_event_error' }
      end
    end
  end
  
  def destroy
    return unless setup && authorize(@event, :editable => true)
    msg = "You have deleted #{@event.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to :back }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    if @user = User.find_by_nick(params[:user_id])
      if @event = Event.find(params[:id], :conditions => ["user_id = ?", @user.id], :include => includes)
        true && authorize(@event)
      else
        error_opts[:message] ||= "That Event entry could not be found. Please check the address."
        display_error(error_opts)
        false
      end
    else
      error_opts[:message] ||= "That User entry could not be found. Please check the address."
      display_error(error_opts)
      false
    end
  end
  
  def authorize(object, opts={})
    return true if !opts[:manual] && !(self.class.read_inheritable_attribute(:authorize_list) || []).include?(action_name.intern)
    unless object && object.accessible_by?(get_viewer) && (!opts[:editable] || object.editable_by?(get_viewer))
      msg = "You are not authorized for that action."
      respond_to_without_type_registration do |format|
        format.html { flash[:warning] = msg; redirect_to get_viewer || login_url }
        format.js { flash.now[:warning] = msg; render :action => 'shared/unauthorized' }
      end
      return false
    end
    true
  end
end
