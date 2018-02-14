require 'test_helper'

class GroupPostLikesControllerTest < ActionController::TestCase
  setup do
    @group_post_like = group_post_likes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:group_post_likes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group_post_like" do
    assert_difference('GroupPostLike.count') do
      post :create, group_post_like: { group_id: @group_post_like.group_id, post_id: @group_post_like.post_id, status: @group_post_like.status, user_id: @group_post_like.user_id }
    end

    assert_redirected_to group_post_like_path(assigns(:group_post_like))
  end

  test "should show group_post_like" do
    get :show, id: @group_post_like
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group_post_like
    assert_response :success
  end

  test "should update group_post_like" do
    patch :update, id: @group_post_like, group_post_like: { group_id: @group_post_like.group_id, post_id: @group_post_like.post_id, status: @group_post_like.status, user_id: @group_post_like.user_id }
    assert_redirected_to group_post_like_path(assigns(:group_post_like))
  end

  test "should destroy group_post_like" do
    assert_difference('GroupPostLike.count', -1) do
      delete :destroy, id: @group_post_like
    end

    assert_redirected_to group_post_likes_path
  end
end
