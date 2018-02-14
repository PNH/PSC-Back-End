require 'test_helper'

class UserConnectionsControllerTest < ActionController::TestCase
  setup do
    @user_connection = user_connections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_connections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_connection" do
    assert_difference('UserConnection.count') do
      post :create, user_connection: {  }
    end

    assert_redirected_to user_connection_path(assigns(:user_connection))
  end

  test "should show user_connection" do
    get :show, id: @user_connection
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_connection
    assert_response :success
  end

  test "should update user_connection" do
    patch :update, id: @user_connection, user_connection: {  }
    assert_redirected_to user_connection_path(assigns(:user_connection))
  end

  test "should destroy user_connection" do
    assert_difference('UserConnection.count', -1) do
      delete :destroy, id: @user_connection
    end

    assert_redirected_to user_connections_path
  end
end
