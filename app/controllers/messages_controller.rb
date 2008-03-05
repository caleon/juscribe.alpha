class MessagesController < ApplicationController
  before_filter :verify_logged_in
  
  verify :method => :post, :only => [ :create, :save_as_draft ]
  
  def index
    
  end
  
  def show
    return unless setup([{:sender => :primary_picture}, {:recipient => :primary_picture}])
    
  end
  
  def new
    @message = @viewer.messages.new
  end
  
  def create
    if @message = Message.create(params[:message])
      msg = "Your message has been " +
            params[:message][:send] ? "sent." : "saved."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @message }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "Your message could not be " +
                            params[:message][:send] ? "sent." : "saved."
      respond_to do |format|
        render :action => 'new'
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
    return unless setup([{ :sender => :primary_picture, :recipient => :primary_picture }])
  end
  
  def update
    if @message.update_attributes(params[:message])
      msg = "Your message has been " +
            (params[:message][:sent] ? "sent." : "saved.")
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @message }
        format.js { flash.now[:notice] = msg }
      end
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    
  end
  
  private
  def setup(includes=nil, opts={})
    if params[:id] && @message = Message.find(params[:id], :include => includes)
      true
    else
      display_error(opts)
      false
    end
  end
end
