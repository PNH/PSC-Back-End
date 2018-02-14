require 'test_helper'

class MembershipCancellationsControllerTest < ActionController::TestCase
  setup do
    @membership_cancellation = membership_cancellations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:membership_cancellations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create membership_cancellation" do
    assert_difference('MembershipCancellation.count') do
      post :create, membership_cancellation: {  }
    end

    assert_redirected_to membership_cancellation_path(assigns(:membership_cancellation))
  end

  test "should show membership_cancellation" do
    get :show, id: @membership_cancellation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @membership_cancellation
    assert_response :success
  end

  test "should update membership_cancellation" do
    patch :update, id: @membership_cancellation, membership_cancellation: {  }
    assert_redirected_to membership_cancellation_path(assigns(:membership_cancellation))
  end

  test "should destroy membership_cancellation" do
    assert_difference('MembershipCancellation.count', -1) do
      delete :destroy, id: @membership_cancellation
    end

    assert_redirected_to membership_cancellations_path
  end
end
