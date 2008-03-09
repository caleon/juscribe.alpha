class EventsController < ApplicationController
  def begin
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
        format.js { render :action => 'begin_error' }
      end
    end
  end
  
  def end
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
        format.js { render :action => 'end_error' }
      end
    end
  end
end
