require 'test_helper'

class GroupPostsControllerTest < ActionController::TestCase
  setup do
    @group_post = group_posts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:group_posts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group_post" do
    assert_difference('GroupPost.count') do
      post :create, group_post: { content: @group_post.content, likes: @group_post.likes, status: @group_post.status, user: @group_post.user }
    end

    assert_redirected_to group_post_path(assigns(:group_post))
  end

  test "should show group_post" do
    get :show, id: @group_post
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group_post
    assert_response :success
  end

  test "should update group_post" do
    patch :update, id: @group_post, group_post: { content: @group_post.content, likes: @group_post.likes, status: @group_post.status, user: @group_post.user }
    assert_redirected_to group_post_path(assigns(:group_post))
  end

  test "should destroy group_post" do
    assert_difference('GroupPost.count', -1) do
      delete :destroy, id: @group_post
    end

    assert_redirected_to group_posts_path
  end
end
