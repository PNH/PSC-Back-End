require 'test_helper'

class HorseProgressLogsControllerTest < ActionController::TestCase
  setup do
    @horse_progress_log = horse_progress_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:horse_progress_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create horse_progress_log" do
    assert_difference('HorseProgressLog.count') do
      post :create, horse_progress_log: {  }
    end

    assert_redirected_to horse_progress_log_path(assigns(:horse_progress_log))
  end

  test "should show horse_progress_log" do
    get :show, id: @horse_progress_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @horse_progress_log
    assert_response :success
  end

  test "should update horse_progress_log" do
    patch :update, id: @horse_progress_log, horse_progress_log: {  }
    assert_redirected_to horse_progress_log_path(assigns(:horse_progress_log))
  end

  test "should destroy horse_progress_log" do
    assert_difference('HorseProgressLog.count', -1) do
      delete :destroy, id: @horse_progress_log
    end

    assert_redirected_to horse_progress_logs_path
  end
end
