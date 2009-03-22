require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_not_nil assigns(:groups)
    assert assigns(:groups).is_a?(Array)
    assert assigns(:groups).inject(true) {|bool, grp| bool && grp.is_a?(Group) }
  end
  
  def test_show
    get :show, groups(:friends).to_path
    assert_response :success
    assert_template 'show'
    assert_equal groups(:friends), assigns(:group)
    assert_not_nil assigns(:users)
    assert assigns(:users).is_a?(Array)
  end
  
  def test_show_when_private
    groups(:friends).rule.toggle_privacy!
    assert groups(:friends).private?
    get :show, groups(:friends).to_path
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show_when_private_but_authorized
    groups(:friends).rule.toggle_privacy!
    assert groups(:friends).private?
    assert groups(:friends).accessible_by?(users(:colin))
    assert !groups(:friends).accessible_by?(users(:nana))
    groups(:friends).rule.allow!(:user, users(:nana))
    assert groups(:friends).accessible_by?(users(:nana))
    get :show, groups(:friends).to_path, as(:nana)
    assert_response :success
    assert_template 'show'
    assert_equal groups(:friends), assigns(:group)
  end
  
  def test_show_when_protected
    groups(:friends).rule.deny!(:user, users(:nana))
    assert groups(:friends).protected?
    assert !groups(:friends).accessible_by?(users(:nana))
    get :show, groups(:friends).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new
    get :new, {}, as(:colin)
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:group)
    assert assigns(:group).new_record?
  end
  
  def test_new_without_user
    get :new
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create
    post :create, { :group => { :name => 'HIMYM lovers' } }, as(:colin)
    assert_not_nil assigns(:group)
    assert assigns(:group).valid?
    assert_redirected_to group_url(assigns(:group))
    assert_equal "You have successfully founded your group.", flash[:notice]
  end
  
  def test_create_without_user
    post :create, { :group => { :name => 'HIMYM lovers' } }
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create_with_wrong_params
    post :create, { :group => { } }, as(:colin)
    assert_template 'new'
    assert !assigns(:group).valid?
    assert_flash_equal "There was an error founding your group.", :warning
  end
  
  def test_edit
    get :edit, groups(:company).to_path, as(:colin)
    assert_response :success
    assert_equal groups(:company), assigns(:group)
  end
  
  def test_edit_without_user
    get :edit, groups(:company).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_edit_with_wrong_user
    get :edit, groups(:company).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_with_wrong_user_whos_boss
    assert !groups(:company).editable_by?(users(:nana))
    groups(:company).rule.add_boss!(:user, users(:nana))
    assert groups(:company).editable_by?(users(:nana))
    get :edit, groups(:company).to_path, as(:nana)
    assert_response :success
    assert_equal groups(:company), assigns(:group)
    assert_template 'edit'
  end
  
  def test_update
    put :update, groups(:company).to_path.merge(:group => { :name => 'blah blah' }), as(:colin)
    assert_redirected_to group_url(groups(:company).reload)
    assert_equal "You have successfully updated #{flash_name_for(groups(:company))}.", flash[:notice]
    assert_equal 'blah blah', groups(:company).reload.name
  end
  
  def test_update_as_non_user
    put :update, groups(:company).to_path.merge(:group => { :name => 'blah blah' })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_as_wrong_user
    put :update, groups(:company).to_path.merge(:group => { :name => 'blah blah' }), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_as_wrong_user_whos_boss
    assert !groups(:company).editable_by?(users(:nana))
    groups(:company).rule.add_boss!(:user, users(:nana))
    assert groups(:company).editable_by?(users(:nana))
    put :update, groups(:company).to_path.merge(:group => { :name => 'blah blah' }), as(:nana)
    assert_redirected_to group_url(groups(:company).reload)
    assert_equal "You have successfully updated #{flash_name_for(groups(:company))}.", flash[:notice]
  end
  
  def test_destroy
    @request.env["HTTP_REFERER"] = 'http://www.cnn.com/'
    delete :destroy, groups(:company).to_path, as(:colin)
    assert_redirected_to 'http://www.cnn.com/'
    assert_equal "You have successfully disbanded #{flash_name_for(groups(:company))}.", flash[:notice]
  end
  
  def test_destroy_by_non_user
    delete :destroy, groups(:company).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_destroy_by_wrong_user
    delete :destroy, groups(:company).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_destroy_by_wrong_user_whos_boss
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    groups(:company).rule.add_boss!(:user, users(:nana))
    delete :destroy, groups(:company).to_path, as(:nana)
    assert_redirected_to 'http://www.cnn.com/'
    assert_equal "You have successfully disbanded #{flash_name_for(groups(:company))}.", flash[:notice]
  end
  
  def test_join
    assert !groups(:company).has_member?(users(:nana))
    put :join, groups(:company).to_path, as(:nana)
    assert_redirected_to group_url(groups(:company))
    assert_equal "You have successfully joined #{flash_name_for(groups(:company))}.", flash[:notice]
    assert groups(:company).has_member?(users(:nana))
  end
  
  def test_join_by_member
    groups(:company).join(users(:nana))
    put :join, groups(:company).to_path, as(:nana)
    assert_redirected_to group_url(groups(:company))
    assert_equal "There was an error joining #{flash_name_for(groups(:company))}.", flash[:warning]
  end
  
  def test_join_by_non_user
    put :join, groups(:company).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_leave
    groups(:company).join(users(:nana))
    put :leave, groups(:company).to_path, as(:nana)
    assert_redirected_to group_url(groups(:company))
    assert_equal "You have successfully left #{flash_name_for(groups(:company))}.", flash[:notice]
    assert !groups(:company).has_member?(users(:nana))
  end
  
  def test_leave_by_non_member
    put :leave, groups(:company).to_path, as(:nana)
    assert_redirected_to group_url(groups(:company))
    assert_equal "There was an error leaving #{flash_name_for(groups(:company))}.", flash[:warning]
    assert !groups(:company).has_member?(users(:nana))
  end
  
  def test_leave_by_non_user
    put :leave, groups(:company).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_kick
    groups(:company).join(users(:nana))
    assert groups(:company).has_member?(users(:nana))
    assert groups(:company).rank_for(users(:colin)) >= Membership::ADMIN_RANK
    put :kick, groups(:company).to_path.merge(:member => users(:nana).id), as(:colin)
    assert_redirected_to group_url(groups(:company))
    assert_equal "You have successfully kicked #{flash_name_for(users(:nana))}.", flash[:notice]
    assert !groups(:company).has_member?(users(:nana))
  end
  
  def test_kick_by_non_user
    put :kick, groups(:company).to_path.merge(:member => users(:nana).id)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_kick_by_wrong_user
    put :kick, groups(:company).to_path.merge(:member => users(:nana).id), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_kick_by_wrong_user_whos_admin
    groups(:company).join(users(:nana), :rank => Membership::ADMIN_RANK)
    assert groups(:company).has_admin?(users(:nana))
    groups(:company).join(users(:alessandra))
    assert groups(:company).has_member?(users(:alessandra))
    put :kick, groups(:company).to_path.merge(:member => users(:alessandra).id), as(:nana)
    assert_redirected_to group_url(groups(:company))
    assert_equal "You have successfully kicked #{flash_name_for(users(:alessandra))}.", flash[:notice]
    assert !groups(:company).has_member?(users(:alessandra))
  end
  
  def test_kick_by_wrong_user_whos_boss
    groups(:company).rule.add_boss!(:user, users(:nana))
    groups(:company).join(users(:alessandra))
    put :kick, groups(:company).to_path.merge(:member => users(:alessandra).id), as(:nana)
    assert_redirected_to group_url(groups(:company))
    assert_equal "You have successfully kicked #{flash_name_for(users(:alessandra))}.", flash[:notice]
  end
  
  def test_kicking_non_member
    assert !groups(:company).has_member?(users(:nana))
    put :kick, groups(:company).to_path.merge(:member => users(:nana).id), as(:colin)
    assert_redirected_to group_url(groups(:company))
    assert_equal "There was an error kicking #{flash_name_for(users(:nana))}.", flash[:warning]
  end
  
  def test_invite
    put :invite, groups(:company).to_path.merge(:member => users(:nana).id), as(:colin)
    assert_redirected_to group_url(groups(:company))
    assert_equal "You have invited #{flash_name_for(users(:nana))} to #{flash_name_for(groups(:company))}.", flash[:notice]
  end
  
  def test_invite_by_non_user
    put :invite, groups(:company).to_path.merge(:member => users(:nana).id)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_invite_by_non_member
    put :invite, groups(:company).to_path.merge(:member => users(:nana).id), as(:alessandra)
    assert_redirected_to group_url(groups(:company))
    assert_equal "There was an error inviting #{flash_name_for(users(:nana))} to #{flash_name_for(groups(:company))}.", flash[:warning]
  end
end
