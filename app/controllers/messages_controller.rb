class MessagesController < ApplicationController  
  use_shared_options :collection_owner => :viewer
  verify_login_on :index, :show, :new, :create, :edit, :update, :destroy, :send
  authorize_on :show, :edit, :update, :destroy, :send
  
  undef_method :edit
  undef_method :update
  #undef_method :destroy
    
  def index
    find_opts = get_find_opts(:order => 'messages.id DESC')
    if params[:show] == 'sent'
      @messages = Message.find(:all, find_opts.merge(:conditions => ["sender_id = ?", get_viewer.id]))
      @page_title = "My Outbox"
    else
      @messages = Message.find(:all, find_opts.merge(:conditions => ["recipient_id = ?", get_viewer.id]))
      @page_title = "My Inbox"
    end
    @user = get_viewer
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def show    
    return unless setup#([ :sender, :recipient ])
    @user = get_viewer
    @message.read_it! if @message.recipient == get_viewer
    @page_title = @message.subject
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
    
  def new
    @page_title = "Compose new message"
    @user = get_viewer
    @recipient = User.primary_find(params[:recipient])
    @message = get_viewer.sent_messages.new
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end  
  
  def create
    @message = Message.new(params[:message].merge(:sender => get_viewer, :recipient => params[:message][:recipient] || params[:recipient]))
    @page_title = "Compose new message"
    if @message.save
      msg = "You have sent your message to #{params[:message][:recipient]}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to message_url(@message) }
        format.js { flash.now[:message] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your message."
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  rescue
    display_error(:message => "There was an error creating your message.")
  end
  
  def destroy
    return unless setup
    if @message.recipient == get_viewer
      @message.nullify!(get_viewer)
      msg = "You have successfully deleted #{flash_name_for(@message)}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to :back }
        format.js { flash.now[:notice] = msg }
      end
    else
      msg = "Only the recipient may delete messages."
      respond_to do |format|
        format.html { flash[:warning] = msg; redirect_to :back }
        format.js { flash.now[:notice] = msg; render :action => 'destroy_error' }
      end
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    @message = Message.primary_find(params[:id], :include => includes)
    authorize(@message)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Message could not be found. Please check the address."
    display_error(error_opts)
    false
  end
  
  def authorize(object, opts={})
    return true if !(self.class.read_inheritable_attribute(:authorize_list) || []).include?(action_name.intern)
    unless object && (object.recipient == get_viewer || object.sender == get_viewer)
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
