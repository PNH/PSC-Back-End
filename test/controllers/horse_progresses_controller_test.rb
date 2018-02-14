require 'test_helper'

class HorseProgressesControllerTest < ActionController::TestCase
  setup do
    @horse_progress = horse_progresses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:horse_progresses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create horse_progress" do
    assert_difference('HorseProgress.count') do
      post :create, horse_progress: {  }
    end

    assert_redirected_to horse_progress_path(assigns(:horse_progress))
  end

  test "should show horse_progress" do
    get :show, id: @horse_progress
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @horse_progress
    assert_response :success
  end

  test "should update horse_progress" do
    patch :update, id: @horse_progress, horse_progress: {  }
    assert_redirected_to horse_progress_path(assigns(:horse_progress))
  end

  test "should destroy horse_progress" do
    assert_difference('HorseProgress.count', -1) do
      delete :destroy, id: @horse_progress
    end

    assert_redirected_to horse_progresses_path
  end
end
