class GroupsController < ApplicationController
  use_shared_options :layoutable => :group
  verify_login_on :new, :create, :edit, :update, :destroy, :join, :leave, :kick, :invite
  authorize_on :show, :edit, :update, :destroy, :kick
  
  def index
    find_opts = get_find_opts(:include => :primary_picture, :order => 'groups.name ASC')
    @groups = Group.find(:all, find_opts)
    @page_title = "Groups on #{APP[:name]}"
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup([:permission, :primary_picture])
    find_opts = get_find_opts(:order => 'memberships.id DESC')
    @users = @group.users.find(:all, find_opts)
    @page_title = @group.display_name
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def new
    @group = Group.new
    @page_title = "New Group"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def create
    @group = get_viewer.found(params[:group], :without_save => true)
    @page_title = "New Group"
    if @group.save
      @group.join(get_viewer, :rank => Membership::RANKS[:founder])
      msg = "You have successfully founded your group."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to group_url(@group) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error founding your group."
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@group, :editable => true)
    @page_title = "#{@group.display_name} - Edit"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@group, :editable => true)
    @page_title = "#{@group.display_name} - Edit"
    if @group.update_attributes(params[:group])
      msg = "You have successfully updated #{@group.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to group_url(@group) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@blog.display_name}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :actin => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@group, :editable => true)
    msg = "You have successfully disbanded #{@group.display_name}."
    @group.disband!(get_viewer)
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to :back }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  def join
    return unless setup
    @page_title = @group.display_name
    if @group.join(get_viewer)
      msg = "You have successfully joined #{@group.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to group_url(@group) }
        format.js { flash.now[:notice] = msg }
      end
    else
      msg = "There was an error joining #{@group.display_name}."
      respond_to do |format|
        format.html { flash[:warning] = msg; redirect_to group_url(@group) }
        format.js { flash.now[:warning] = msg; render :action => 'join_error' }
      end
    end
  end
  
  def leave
    return unless setup
    if @group.kick(get_viewer)
      msg = "You have successfully left #{@group.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to group_url(@group) }
        format.js { flas.now[:notice] = msg }
      end
    else
      msg = "There was an error leaving #{@group.display_name}."
      respond_to do |format|
        format.html { flash[:warning] = msg; redirect_to group_url(@group) }
        format.js { flash.now[:warning] = msg; render :action => 'leave_error' }
      end
    end
  end
  
  def kick
    return unless setup(:permission) && authorize(@group, :editable => true)
    if @group.kick(user = User.find(params[:member]))
      msg = "You have successfully kicked #{user.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to group_url(@group) }
        format.js { flash.now[:notice] = msg }
      end
    else
      msg = "There was an error kicking #{user.display_name}."
      respond_to do |format|
        format.html { flash[:warning] = msg; redirect_to group_url(@group) }
        format.js { flash.now[:warning] = msg; render :action => 'kick_error' }
      end
    end
  rescue ActiveRecord::RecordNotFound
    display_error(:message => "That User could not be found. Please check the address.")
  end
  
  def invite
    return unless setup(:permission)
    if @group.invite({:to_user => (user = User.find(params[:member])), :from_user => get_viewer})
      msg = "You have invited #{user.display_name} to #{@group.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to group_url(@group) }
        format.js { flash.now[:notice] = msg }
      end
    else
      msg = "There was an error inviting #{user.display_name} to #{@group.display_name}."
      respond_to do |format|
        format.html { flash[:warning] = msg; redirect_to group_url(@group) }
        format.js { flash.now[:warning] = msg; render :action => 'invite_error' }
      end
    end
  rescue ActiveRecord::RecordNotFound
    display_error(:message => "That User could not be found. Please check the address.")
  end
  
  private
  def setup(includes=nil, error_opts={})
    @group = Group.primary_find(params[:id], :include => includes)
    raise ActiveRecord::RecordNotFound if @group.nil?
    authorize(@group)
  rescue ActiveRecord::RecordNotFound
    display_error(:message => error_opts[:message] || "That Group could not be found. Please check the address.")
    false
  end
end
