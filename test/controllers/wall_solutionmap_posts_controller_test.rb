require 'test_helper'

class WallSolutionmapPostsControllerTest < ActionController::TestCase
  setup do
    @wall_solutionmap_post = wall_solutionmap_posts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wall_solutionmap_posts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wall_solutionmap_post" do
    assert_difference('WallSolutionmapPost.count') do
      post :create, wall_solutionmap_post: {  }
    end

    assert_redirected_to wall_solutionmap_post_path(assigns(:wall_solutionmap_post))
  end

  test "should show wall_solutionmap_post" do
    get :show, id: @wall_solutionmap_post
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wall_solutionmap_post
    assert_response :success
  end

  test "should update wall_solutionmap_post" do
    patch :update, id: @wall_solutionmap_post, wall_solutionmap_post: {  }
    assert_redirected_to wall_solutionmap_post_path(assigns(:wall_solutionmap_post))
  end

  test "should destroy wall_solutionmap_post" do
    assert_difference('WallSolutionmapPost.count', -1) do
      delete :destroy, id: @wall_solutionmap_post
    end

    assert_redirected_to wall_solutionmap_posts_path
  end
end
