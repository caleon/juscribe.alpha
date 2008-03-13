class EventsController < ApplicationController
  use_shared_options
  verify_login_on :new, :create, :edit, :update, :destroy, :begin_event, :end_event
  authorize_on :edit, :update, :destroy, :begin_event, :end_event
  
  def index
    @user = User.primary_find(params[:user_id])
  end
  
  def begin_event
    return unless setup && request.method == :put && verify_logged_in && authorize(@event)
    if @event.begin!
      msg = "Your event #{@event.display_name} has officially begun!"
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @event }
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
    return unless setup && request.method == :put && verify_logged_in && authorize(@event)
    if @event.end!
      msg = "Your event #{@event.display_name} has officially ended!"
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @event }
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
end
