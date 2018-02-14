require 'test_helper'

class EventPricingsControllerTest < ActionController::TestCase
  setup do
    @event_pricing = event_pricings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_pricings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_pricing" do
    assert_difference('EventPricing.count') do
      post :create, event_pricing: {  }
    end

    assert_redirected_to event_pricing_path(assigns(:event_pricing))
  end

  test "should show event_pricing" do
    get :show, id: @event_pricing
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_pricing
    assert_response :success
  end

  test "should update event_pricing" do
    patch :update, id: @event_pricing, event_pricing: {  }
    assert_redirected_to event_pricing_path(assigns(:event_pricing))
  end

  test "should destroy event_pricing" do
    assert_difference('EventPricing.count', -1) do
      delete :destroy, id: @event_pricing
    end

    assert_redirected_to event_pricings_path
  end
end
