require 'test_helper'

class GroupPostAttachmentsControllerTest < ActionController::TestCase
  setup do
    @group_post_attachment = group_post_attachments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:group_post_attachments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group_post_attachment" do
    assert_difference('GroupPostAttachment.count') do
      post :create, group_post_attachment: { group_post_id: @group_post_attachment.group_post_id, rich_file_id: @group_post_attachment.rich_file_id, status: @group_post_attachment.status }
    end

    assert_redirected_to group_post_attachment_path(assigns(:group_post_attachment))
  end

  test "should show group_post_attachment" do
    get :show, id: @group_post_attachment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group_post_attachment
    assert_response :success
  end

  test "should update group_post_attachment" do
    patch :update, id: @group_post_attachment, group_post_attachment: { group_post_id: @group_post_attachment.group_post_id, rich_file_id: @group_post_attachment.rich_file_id, status: @group_post_attachment.status }
    assert_redirected_to group_post_attachment_path(assigns(:group_post_attachment))
  end

  test "should destroy group_post_attachment" do
    assert_difference('GroupPostAttachment.count', -1) do
      delete :destroy, id: @group_post_attachment
    end

    assert_redirected_to group_post_attachments_path
  end
end
