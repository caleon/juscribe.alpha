class PermissionsController < ApplicationController
  # TODO: view lets you MERGE parts of each of the rules. Need to feed model attrs hash.
  use_shared_options :permission_rule, :collection_layoutable => :get_viewer
  verify_login_on :index, :show, :new, :create, :edit, :update, :destroy
  authorize_on :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    @permission_rules = @user.permission_rules
    @page_title = "#{@user.display_name}'s Permission Rules"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def show
    return unless setup(:permissions)
    @page_title = @permission_rule.display_name
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def new
    @permission_rule = get_viewer.permission_rules.new
    @page_title = "New Permission Rule"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def create
    @permission_rule = PermissionRule.new(params[:permission_rule].merge(:user => get_viewer))
    @page_title = "New Permission Rule"
    if @permission_rule.save
      msg = "You have successfully created a permission rule."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to permission_url(@permission_rule) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your permission rule."
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup
    @page_title = "#{@permission_rule.display_name} - Edit"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update
    return unless setup
    @page_title = "#{@permission_rule.display_name} - Edit"
    if @permission_rule.update_attributes(params[:permission_rule])
      msg = "You have successfully updated #{@permission_rule.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to permission_url(@permission_rule) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating #{@permission_rule.display_name}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup
    @permission_rule.nullify!(get_viewer)
    msg = "You have deleted the permission rule #{@permission_rule.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to permissions_url }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    @permission_rule = PermissionRule.primary_find(params[:id], :include => includes)
    raise ActiveRecord::RecordNotFound if @permission_rule.nil?
    authorize(@permission_rule)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Permission Rule could not be found. Please check the address."
    display_error(error_opts)
    false
  end
  
  def authorize(object, opts={})
    return true if !(self.class.read_inheritable_attribute(:authorize_list) || []).include?(action_name.intern)
    unless object && object.user == get_viewer
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
