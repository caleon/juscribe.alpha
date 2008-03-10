# TODO: setup controller-level check for #accessible_by?
class MessagesController < ApplicationController  
  verify_login_on :index, :show, :new, :create, :edit, :update, :destroy, :send
  # Following allows #setup to check editable_by? with get_viewer
  authorize_on :show, :edit, :update, :destroy, :send
  
  def index
    raise ArgumentError unless (params[:show].nil? || ['draft', 'sent'].include?(params[:show]))
    find_opts = get_find_opts(:order => 'id DESC')
    method_part = params.delete(:show).to_s.gsub!(/(draft|sent)/, '\1_')
    @messages = get_viewer.send(:"some_#{method_part}messages").find(:all, find_opts)
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
  
  def edit
    super(:include => [ :sender, :recipient ])
  end
  
  def update
    super do |marker|
      case marker
      when :before_response
        msg = "Your message has been " + (params[:message][:transmit] ? "sent." : "saved.")
      end
    end
  end
  
  def send
    return unless setup
    if @message.transmit
      msg = "Your message has been sent."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @message }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning]  = "Your message could not be sent."
      respond_to do |format|
        format.html { render :action => 'show' }
        format.js { render :action => 'send_error' }
      end
    end
  end
end
