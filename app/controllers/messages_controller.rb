# TODO: setup controller-level check for #accessible_by?
class MessagesController < ApplicationController  
  use_shared_options
  verify_login_on :index, :show, :new, :create, :edit, :update, :destroy, :send
  authorize_on :show, :edit, :update, :destroy, :send
  
  undef_method :edit
  undef_method :update
  undef_method :destroy
    
  def index
    find_opts = get_find_opts(:order => 'messages.id DESC')
    if params[:show] == 'sent'
      @messages = Message.find(:all, find_opts.merge(:conditions => ["sender_id = ?", get_viewer.id]))
    else
      @messages = Message.find(:all, find_opts.merge(:conditions => ["recipient_id = ?", get_viewer.id]))
    end
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  rescue ArgumentError, NoMethodError
    display_error(:message => 'Invalid option for mailbox view. Please check the address.')
  end
  
  def show    
    return unless setup#([ :sender, :recipient ])
    @message.read_it! if @recipient == get_viewer
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
    
  def create
    @message = Message.new(params[:message].merge(:sender => get_viewer))
    if @message.save
      msg = "You have sent your message to #{params[:message][:recipient]}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to message_url(@message) }
        format.js { flash.now[:message] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your message."
      respond_to do |format|
        format.html { render :action => "new" }
        format.js { render :action => 'create_error' }
      end
    end
  rescue
    display_error(:message => "There was an error creating your message.")
  end
end
