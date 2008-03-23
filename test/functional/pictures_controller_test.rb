require File.dirname(__FILE__) + '/../test_helper'

class PicturesControllerTest < ActionController::TestCase

  def test_index_on_user
    get :index, users(:colin).to_path(true)
    assert_response :success
    assert_template 'index'
    assert_equal users(:colin), assigns(:depictable)
    assert_not_nil assigns(:pictures)
    assert assigns(:pictures).is_a?(Array)
    assert assigns(:pictures).inject(true) {|bool, pic| bool && pic.is_a?(Picture) }
  end
  
  def test_index_on_article
    articles(:blog).publish!
    get :index, articles(:blog).to_path(true)
    assert_response :success
    assert_template 'index'
    assert_equal articles(:blog), assigns(:depictable)
    assert_not_nil assigns(:pictures)
    assert assigns(:pictures).is_a?(Array)
    assert assigns(:pictures).inject(true) {|bool, pic| bool && pic.is_a?(Picture) }
  end
  
  def test_index_on_blog_of_group
    assert blogs(:company).to_path(true).keys.include?(:blog_id)
    assert blogs(:company).to_path(true).keys.include?(:group_id)
    get :index, blogs(:company).to_path(true)
    assert_response :success
    assert_template 'index'
    assert_equal blogs(:company), assigns(:depictable)
    assert_not_nil assigns(:pictures)
    assert assigns(:pictures).is_a?(Array)
    assert assigns(:pictures).inject(true) {|bool, pic| bool && pic.is_a?(Picture) }
  end
  
  def test_index_on_protected_blog_as_non_user
    assert blogs(:company).public?
    blogs(:company).rule.deny!(:user, users(:keira))
    assert blogs(:company).protected?
    get :index, blogs(:company).to_path(true)
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_index_on_protected_blog_as_denied_user
    blogs(:company).rule.deny!(:user, users(:keira))
    get :index, blogs(:company).to_path(true), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_index_on_private_blog_as_non_user
    blogs(:company).rule.toggle_privacy!
    get :index, blogs(:company).to_path(true)
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_index_on_private_blog_as_denied_user
    blogs(:company).rule.toggle_privacy!
    get :index, blogs(:company).to_path(true), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_index_on_private_blog_as_allowed_user
    blogs(:company).rule.toggle_privacy!
    blogs(:company).rule.allow!(:user, users(:nana))
    get :index, blogs(:company).to_path(true), as(:nana)
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:pictures)
    assert_equal blogs(:company), assigns(:depictable)
    assert assigns(:pictures).is_a?(Array)
    assert assigns(:pictures).inject(true) {|bool, pic| bool && pic.is_a?(Picture) }
  end
  
  def test_index_with_malformed_url
    get :index, blogs(:company).to_path(true).merge(:blog_id => '123'), as(:colin)
    assert_template 'error'
    assert_flash_equal 'Unable to find the object specified. Please check the address.', :warning
  end
  
  def test_show
    get :show, pictures(:gallery_item1).to_path
    assert_response :success
    assert_equal pictures(:gallery_item1), assigns(:picture)
    assert_equal pictures(:gallery_item1).depictable, assigns(:depictable)
  end
  
  def test_show_private_as_non_user
    pictures(:gallery_item1).rule.toggle_privacy!
    get :show, pictures(:gallery_item1).to_path
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show_private_as_denied_user
    pictures(:gallery_item1).rule.toggle_privacy!
    get :show, pictures(:gallery_item1).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show_private_as_owner
    pictures(:gallery_item1).rule.toggle_privacy!
    get :show, pictures(:gallery_item1).to_path, as(:colin)
    assert_response :success
    assert_not_nil assigns(:picture)
    assert_equal pictures(:gallery_item1), assigns(:picture)
    assert_equal users(:colin), assigns(:depictable)
    assert_equal assigns(:picture).depictable, assigns(:depictable)
  end
  
  def test_new
    get :new, users(:keira).to_path(true), as(:colin)
    assert_equal users(:keira), assigns(:depictable)
    assert_template 'new'
    assert_not_nil assigns(:picture)
    assert assigns(:picture).new_record?
  end
  
  def test_new_without_user
    get :new, users(:keira).to_path(true)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_new_on_private_depictable
    users(:keira).rule.toggle_privacy!
    get :new, users(:keira).to_path(true), as(:colin)
    assert_redirected_to user_url(users(:colin))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new_on_private_depictable_as_depictable
    users(:keira).rule.toggle_privacy!
    get :new, users(:keira).to_path(true), as(:keira)
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:picture)
    assert_equal users(:keira), assigns(:depictable)
    assert assigns(:picture).new_record?
  end
  
  def test_new_with_malformed_url
    get :new, users(:keira).to_path(true).merge(:user_id => 'keir'), as(:colin)
    assert_template 'error'
    assert_flash_equal 'Unable to find the object to depict. Please check the address.', :warning
  end
  
  def test_create
    post :create, users(:keira).to_path(true).merge(:picture => { :uploaded_data => fixture_file_upload("keira.jpg", "image/jpg") }), as(:colin)
    assert_not_nil assigns(:picture)
    assert assigns(:picture).valid?
    assert_not_nil assigns(:picture).depictable
    assert_equal users(:keira), assigns(:picture).depictable
    assert_redirected_to assigns(:picture).to_path.merge(:action => 'edit')
    assert_equal "Your picture has been uploaded.", flash[:notice]
  end
  
  def test_create_without_user
    post :create, users(:keira).to_path(true).merge(:picture => { :uploaded_data => fixture_file_upload("keira.jpg", "image/jpg") })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create_on_private_depictable_as_denied
    users(:keira).rule.toggle_privacy!
    post :create, users(:keira).to_path(true).merge(:picture => { :uploaded_data => fixture_file_upload("keira.jpg", "image/jpg") }), as(:colin)
    assert_redirected_to user_url(users(:colin))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_create_with_invalidly_huge_image
    post :create, users(:jessica).to_path(true).merge(:picture => { :uploaded_data => fixture_file_upload("jessica.jpg", "image/jpg") }), as(:colin)
    assert assigns(:picture).new_record?
    assert_flash_equal "Sorry, could not save the uploaded picture. Please upload another picture.", :warning
    assert_template 'new'
  end
    
  def test_edit
    get :edit, pictures(:gallery_item1).to_path, as(:colin)
    assert_response :success
    assert_template 'edit'
    assert_equal pictures(:gallery_item1), assigns(:picture)
    assert_equal users(:colin), assigns(:depictable)
  end
  
  def test_edit_without_user
    get :edit, pictures(:gallery_item1).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_edit_with_diff_user
    get :edit, pictures(:gallery_item1).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_as_depictable_user
    get :edit, pictures(:gallery_item2).to_path, as(:keira)
    assert_response :success
    assert_equal pictures(:gallery_item2), assigns(:picture)
    assert_equal users(:keira), assigns(:depictable)
  end
  
  def test_edit_with_depictable_editable_by_user
    pictures(:for_blog).rule.toggle_privacy!
    assert !pictures(:for_blog).editable_by?(users(:keira))
    assert_equal articles(:blog), pictures(:for_blog).depictable
    articles(:blog).send(:make_permalink, :with_save => true)
    assert_not_nil pictures(:for_blog).depictable.pictures.find('for_blog'.hash.abs)
    assert !articles(:blog).editable_by?(users(:keira))
    articles(:blog).rule.add_boss!(:user, users(:keira))
    assert articles(:blog).editable_by?(users(:keira))
    assert pictures(:for_blog).reload.editable_by?(users(:keira))
    assert pictures(:for_blog).accessible_by?(users(:keira))
    get :edit, pictures(:for_blog).to_path, as(:keira)
    assert_equal articles(:blog), assigns(:depictable), pictures(:for_blog).to_path
    assert_response :success
    assert_template 'edit'
    assert_equal pictures(:for_blog), assigns(:picture)
    assert_equal articles(:blog), assigns(:picture).depictable
  end
  
  def test_crop
    post :create, users(:keira).to_path(true).merge(:picture => { :uploaded_data => fixture_file_upload("keira.jpg", "image/jpg") }), as(:colin)
    pic = assigns(:picture)
    crop_params = { :crop_left => 0, :crop_top => 0, :crop_width => 300, :crop_height => 300, :stencil_width => 300, :stencil_height => 300, :resize_to_stencil => 'false', :crop_cancel => 'false' }
    put :update, assigns(:picture).to_path.merge(:picture_crop => crop_params, :picture => { :do_crop => 'Crop' }), as(:colin)
    assert_redirected_to assigns(:picture).to_path
    assert_equal 300, pic.reload.width
    assert pic.updated_at > 1.minute.ago # Can't check for flash[:notice] cuz of post.
  end
  
  def test_just_update
    articles(:blog).send(:make_permalink, :with_save => true)
    assert_not_equal 300, pictures(:for_blog).width
    orig_width = pictures(:for_blog).width
    crop_params = { :crop_left => 0, :crop_top => 0, :crop_width => 300, :crop_height => 300, :stencil_width => 300, :stencil_height => 300, :resize_to_stencil => 'false', :crop_cancel => 'false' }
    put :update, pictures(:for_blog).to_path.merge(:picture_crop => crop_params, :picture => { :name => 'Just a new name for pic' }), as(:colin)
    assert_redirected_to pictures(:for_blog).to_path
    assert_equal "You have successfully edited your image.", flash[:notice]
    assert_equal orig_width, pictures(:for_blog).reload.width
  end
  
  def test_just_update_with_wrong_params
    articles(:blog).send(:make_permalink, :with_save => true)
    put :update, pictures(:for_blog).to_path.merge(:picture => { :caption => '1' }), as(:colin)
    assert_template 'edit'
    assert_flash_equal "There was an error editing your picture: Validation failed: Caption is too short (minimum is 3 characters), Caption is invalid", :warning
  end
  
  def test_just_update_with_wrong_crop
    post :create, users(:keira).to_path(true).merge(:picture => { :uploaded_data => fixture_file_upload("keira.jpg", "image/jpg") }), as(:colin)
    pic = assigns(:picture)
    crop_params = { :crop_left => 0, :crop_top => 0, :crop_width => -100, :crop_height => 300, :stencil_width => 200, :stencil_height => 300, :resize_to_stencil => 'false', :crop_cancel => 'false' }
    put :update, pic.to_path.merge(:picture_crop => crop_params, :picture => { :do_crop => 'Crop' }), as(:colin)
    assert_template 'edit'
    assert_flash_equal "There was an error editing your picture: Picture::InvalidCropRect", :warning
  end
  
  def test_destroy
    pictures(:for_blog).depictable.send(:make_permalink, :with_save => true)
    assert_equal articles(:blog), pictures(:for_blog).depictable
    assert_not_nil articles(:blog)[:permalink]
#    flunk pictures(:for_blog).to_path.inspect
    delete :destroy, pictures(:for_blog).to_path, as(:colin)
    assert_redirected_to articles(:blog).to_path
    assert_equal "You have deleted a picture on #{articles(:blog).display_name}.", flash[:notice]
  end
end
