class MessagesController < ApplicationController  
  def show
    super(:include => [ { :sender => :primary_picture },
                        { :recipient => :primary_picture } ])
  end
  
  def create
    super do |marker|
      case marker
      when :before_response
        msg = "Your message has been " + params[:message][:send] ? "sent." : "saved."
      when :before_error_response
        flash.now[:warning] = "Your message could not be " +
                              params[:message][:send] ? "sent." : "saved."
      end
    end
  end
  
  def send
    return unless setup
    if @message.send
      msg = "Your message has been sent."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @message }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning]  = "Your message could not be sent."
      respond_to do |format|
        render :action => 'show'
      end
    end
  end
  
  def edit
    super(:include => [ { :sender => :primary_picture },
                        { :recipient => :primary_picture } ])
  end
  
  def update
    super do |marker|
      case marker
      when :before_response
        msg = "Your message has been " + (params[:message][:sent] ? "sent." : "saved.")
      end
    end
  end
end
