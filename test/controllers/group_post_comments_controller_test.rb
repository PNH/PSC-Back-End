require 'test_helper'

class GroupPostCommentsControllerTest < ActionController::TestCase
  setup do
    @group_post_comment = group_post_comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:group_post_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group_post_comment" do
    assert_difference('GroupPostComment.count') do
      post :create, group_post_comment: { comment: @group_post_comment.comment, group_post: @group_post_comment.group_post, parent_id: @group_post_comment.parent_id, user_id: @group_post_comment.user_id }
    end

    assert_redirected_to group_post_comment_path(assigns(:group_post_comment))
  end

  test "should show group_post_comment" do
    get :show, id: @group_post_comment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group_post_comment
    assert_response :success
  end

  test "should update group_post_comment" do
    patch :update, id: @group_post_comment, group_post_comment: { comment: @group_post_comment.comment, group_post: @group_post_comment.group_post, parent_id: @group_post_comment.parent_id, user_id: @group_post_comment.user_id }
    assert_redirected_to group_post_comment_path(assigns(:group_post_comment))
  end

  test "should destroy group_post_comment" do
    assert_difference('GroupPostComment.count', -1) do
      delete :destroy, id: @group_post_comment
    end

    assert_redirected_to group_post_comments_path
  end
end
