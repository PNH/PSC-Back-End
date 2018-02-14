require 'test_helper'

class EventInstructorsControllerTest < ActionController::TestCase
  setup do
    @event_instructor = event_instructors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_instructors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_instructor" do
    assert_difference('EventInstructor.count') do
      post :create, event_instructor: {  }
    end

    assert_redirected_to event_instructor_path(assigns(:event_instructor))
  end

  test "should show event_instructor" do
    get :show, id: @event_instructor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_instructor
    assert_response :success
  end

  test "should update event_instructor" do
    patch :update, id: @event_instructor, event_instructor: {  }
    assert_redirected_to event_instructor_path(assigns(:event_instructor))
  end

  test "should destroy event_instructor" do
    assert_difference('EventInstructor.count', -1) do
      delete :destroy, id: @event_instructor
    end

    assert_redirected_to event_instructors_path
  end
end
