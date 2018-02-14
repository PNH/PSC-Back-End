require 'test_helper'

class EventCategoryMappingsControllerTest < ActionController::TestCase
  setup do
    @event_category_mapping = event_category_mappings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_category_mappings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_category_mapping" do
    assert_difference('EventCategoryMapping.count') do
      post :create, event_category_mapping: {  }
    end

    assert_redirected_to event_category_mapping_path(assigns(:event_category_mapping))
  end

  test "should show event_category_mapping" do
    get :show, id: @event_category_mapping
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_category_mapping
    assert_response :success
  end

  test "should update event_category_mapping" do
    patch :update, id: @event_category_mapping, event_category_mapping: {  }
    assert_redirected_to event_category_mapping_path(assigns(:event_category_mapping))
  end

  test "should destroy event_category_mapping" do
    assert_difference('EventCategoryMapping.count', -1) do
      delete :destroy, id: @event_category_mapping
    end

    assert_redirected_to event_category_mappings_path
  end
end
