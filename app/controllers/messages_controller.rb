# TODO: setup controller-level check for #accessible_by?
class MessagesController < ApplicationController  
  use_shared_options
  verify_login_on :index, :show, :new, :create, :edit, :update, :destroy, :send
  authorize_on :show, :edit, :update, :destroy, :send
  
  # Following allows #setup to check editable_by? with get_viewer
  
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
    display_error(:message => 'Invalid option for mailbox view. Please check your URL.')
  end
  
  def show
    super(:include => [ :sender, :recipient ]) do |marker|
      case marker
      when :before_response
        @sender, @recipient = @message.sender, @message.recipient
        @message.read_it! if @recipient = get_viewer
      end
    end
  end
  
  def create
    super do |marker|
      case marker
      when :before_response
        msg = "Your message has been " + params[:message][:transmit] ? "sent." : "saved."
        # HMMM. Will this look for Message#transmit= method?
      when :before_error_response
        flash.now[:warning] = "Your message could not be " +
                              params[:message][:transmit] ? "sent." : "saved."
      end
    end
  end
  
end
