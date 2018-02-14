require 'test_helper'

class EventLocationsControllerTest < ActionController::TestCase
  setup do
    @event_location = event_locations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_locations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_location" do
    assert_difference('EventLocation.count') do
      post :create, event_location: {  }
    end

    assert_redirected_to event_location_path(assigns(:event_location))
  end

  test "should show event_location" do
    get :show, id: @event_location
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_location
    assert_response :success
  end

  test "should update event_location" do
    patch :update, id: @event_location, event_location: {  }
    assert_redirected_to event_location_path(assigns(:event_location))
  end

  test "should destroy event_location" do
    assert_difference('EventLocation.count', -1) do
      delete :destroy, id: @event_location
    end

    assert_redirected_to event_locations_path
  end
end
