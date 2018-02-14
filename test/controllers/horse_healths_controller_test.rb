require 'test_helper'

class HorseHealthsControllerTest < ActionController::TestCase
  setup do
    @horse_health = horse_healths(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:horse_healths)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create horse_health" do
    assert_difference('HorseHealth.count') do
      post :create, horse_health: {  }
    end

    assert_redirected_to horse_health_path(assigns(:horse_health))
  end

  test "should show horse_health" do
    get :show, id: @horse_health
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @horse_health
    assert_response :success
  end

  test "should update horse_health" do
    patch :update, id: @horse_health, horse_health: {  }
    assert_redirected_to horse_health_path(assigns(:horse_health))
  end

  test "should destroy horse_health" do
    assert_difference('HorseHealth.count', -1) do
      delete :destroy, id: @horse_health
    end

    assert_redirected_to horse_healths_path
  end
end
