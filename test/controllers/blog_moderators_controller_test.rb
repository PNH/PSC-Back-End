require 'test_helper'

class BlogModeratorsControllerTest < ActionController::TestCase
  setup do
    @blog_moderator = blog_moderators(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:blog_moderators)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create blog_moderator" do
    assert_difference('BlogModerator.count') do
      post :create, blog_moderator: {  }
    end

    assert_redirected_to blog_moderator_path(assigns(:blog_moderator))
  end

  test "should show blog_moderator" do
    get :show, id: @blog_moderator
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @blog_moderator
    assert_response :success
  end

  test "should update blog_moderator" do
    patch :update, id: @blog_moderator, blog_moderator: {  }
    assert_redirected_to blog_moderator_path(assigns(:blog_moderator))
  end

  test "should destroy blog_moderator" do
    assert_difference('BlogModerator.count', -1) do
      delete :destroy, id: @blog_moderator
    end

    assert_redirected_to blog_moderators_path
  end
end
