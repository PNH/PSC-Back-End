require 'test_helper'

class LevelChecklistsControllerTest < ActionController::TestCase
  setup do
    @level_checklist = level_checklists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:level_checklists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create level_checklist" do
    assert_difference('LevelChecklist.count') do
      post :create, level_checklist: { content: @level_checklist.content, level_id: @level_checklist.level_id, status: @level_checklist.status, title: @level_checklist.title }
    end

    assert_redirected_to level_checklist_path(assigns(:level_checklist))
  end

  test "should show level_checklist" do
    get :show, id: @level_checklist
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @level_checklist
    assert_response :success
  end

  test "should update level_checklist" do
    patch :update, id: @level_checklist, level_checklist: { content: @level_checklist.content, level_id: @level_checklist.level_id, status: @level_checklist.status, title: @level_checklist.title }
    assert_redirected_to level_checklist_path(assigns(:level_checklist))
  end

  test "should destroy level_checklist" do
    assert_difference('LevelChecklist.count', -1) do
      delete :destroy, id: @level_checklist
    end

    assert_redirected_to level_checklists_path
  end
end
