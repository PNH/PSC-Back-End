require 'test_helper'

class EventOrganizersControllerTest < ActionController::TestCase
  setup do
    @event_organizer = event_organizers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_organizers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_organizer" do
    assert_difference('EventOrganizer.count') do
      post :create, event_organizer: {  }
    end

    assert_redirected_to event_organizer_path(assigns(:event_organizer))
  end

  test "should show event_organizer" do
    get :show, id: @event_organizer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_organizer
    assert_response :success
  end

  test "should update event_organizer" do
    patch :update, id: @event_organizer, event_organizer: {  }
    assert_redirected_to event_organizer_path(assigns(:event_organizer))
  end

  test "should destroy event_organizer" do
    assert_difference('EventOrganizer.count', -1) do
      delete :destroy, id: @event_organizer
    end

    assert_redirected_to event_organizers_path
  end
end
