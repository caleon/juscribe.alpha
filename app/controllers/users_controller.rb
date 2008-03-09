class UsersController < ApplicationController
  #before_filter :verify_logged_in, :except => [ :login, :new, :friends, :about ]

  #verify :method => :get, :only => [ :friends, :mailbox, :about, :edit_password, :logout, :mine ]
  #verify :method => :put, :only => [ :update_password, :unfriend, :befriend ]
  
      
  def show
    super(:includes => :permission) do |marker|
      case marker
      when :after_setup
        @widgets = @user.widgets.placed # TODO: cant :include :widgetable. write sql.
        @skin_file = @user.skin_file
        @layout_file = @user.layout_file
      end
    end
  end
  
  def create
    super(:without_association => true) do |marker|
      case marker
      when :after_instantiate
        @user = @object
        @user.nick, @user.email = params[:user][:nick], params[:user][:email]
      when :after_save
        create_uploaded_picture_for(@user) if picture_uploaded?
        session[:user_id] = @user.id
      when :before_response
        msg = "You are now a registered user! Welcome!"
      when :before_error_response
        flash.now[:warning] = "There was an issue with the registration form."
      end
    end
  end
  
  # Try:
  def method_defined(m, *args)
    define_method(m, *args) {
      options = *args.extract_options!
      super(options) do |marker|
        m.call(*args)
      end
    }
  end
  
  def update
    super do |marker|
      case marker
      when :after_setup
        save_uploaded_picture_for(@user) if picture_uploaded?
      end
    end
  end
  
  def edit_password
    return unless (setup && @user.editable_by?(@viewer))
    @page_title = "#{@user.nick} - Edit Password"
  end
  
  def update_password
    return unless (setup && @user.editable_by?(@viewer))
    if @user.update_attributes(params[:user])
      msg = "You have successfully changed your password."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @user }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an issue with the change password form."
      respond_to do |format|
        format.html { render :action => 'edit_password' }
        format.js { render :action => 'update_password_error' }
      end
    end      
  end
  
  def destroy
    super
  end
  
  def login # login and logout actions only responds to html
    @page_title = "Login"
    if request.post?
      if (@user = User.find_by_nick(params[:user][:nick])) && @user.authenticate(params[:user][:password])
        session[:user_id] = @user.id
        flash[:notice] = "You are now logged in."
        redirect_to @user
      else
        flash.now[:warning] = "There was an error logging you in."
        @user ||= User.new
        @user.errors.add(:nick, "is not a user in our database.") unless @user.nick
      end
    else
      if session[:user_id]
        user = @viewer
        flash[:notice] = "You are already logged in."
        redirect_to user
      else
        @user = User.new
      end
    end
  end
  
  def logout
    redirect_to user_url(@viewer)
    session[:user_id] = nil
    reset_session
    flash[:notice] = "You are now logged out. See you soon!" # Needs to be set after reset_session.
  end
  
  def mine
    redirect_to User.find(session[:user_id])
  end
  
  def friends
    return unless setup
    @friends = @user.friends(:include => [:primary_picture, {:permission => :permission_rule}])
  end
  
  def befriend
    return unless setup
    if res = @viewer.befriend(@user) # This sends out notifier in model.
      @notice = [ "You have requested friendship with #{@user}.",
                  "You are now friends with #{@user}." ][res]
      respond_to do |format|
        format.html do
          flash[:notice] = @notice
          redirect_to @user
        end
        format.js          
      end
    else
      flash.now[:warning] = "There wasn an error friending #{@user.display_name}."
      respond_to do |format|
        format.html do
          params[:id] = @viewer.nick
          show
          render :action => 'show'
        end
        format.js { render :action => 'befriend_error' }
      end
    end
  end
  
  def unfriend
    return unless setup
    if @viewer.kinda_friends_with?(@user) && @viewer.unfriend(@user)
      msg = "You are no longer friends with #{@user.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @viewer }
        format.js { flash.now[:notice] = msg; }
      end
    else
      flash.now[:warning] = "You cannot unfriend #{@user.display_name}."
      respond_to do |format|
        format.html do
          params[:id] = @viewer.friends_with?(@user) ? @user.nick : @viewer.nick
          show
          render :action => 'show'
        end
        format.js { render :action => 'unfriend_error'}
      end
    end
  end
  
  def mailbox
    # FIXME: The following includes array makes it draw ALL associated messages.
    return unless setup([{ :messages => { :sender => :primary_picture } },
                         { :sent_messages => { :recipient => :primary_picture } },
                         { :drafts => {:recipient => :primary_picture } }])
    @messages = @viewer.messages.find(:all, :include => {:sender => :primary_picture}, :limit => 20)
    @sent_messages = @viewer.sent_messages.find(:all, :include => {:recipient => :primary_picture}, :limit => 20)
    @drafts = @viewer.drafts.find(:all, :include => {:recipient => :primary_picture}, :limit => 20)
  end
  
  def about
    return unless setup
  end
  
  private
  def run_initialize
    @klass = User
    @instance_name = 'user'
    @instance_str = 'user'
    @instance_var = "@user"
    @instance_sym = :user
    @plural_sym = "users"
    @custom_finder = :find_by_nick
  end
  
  def authorize(object=@user)
    return true unless [ :edit_password,:update_password, :befriend, :unfriend ].include?(action_name.intern)
    object && @viewer && object.editable_by?(@viewer)
  end
end
