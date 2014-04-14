require 'test_helper'

class ProjectSubjectsControllerTest < ActionController::TestCase
  setup do
    @project_subject = project_subjects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:project_subjects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_subject" do
    assert_difference('ProjectSubject.count') do
      post :create, project_subject: { priority: @project_subject.priority, properties: @project_subject.properties, seen_user_ids: @project_subject.seen_user_ids, zooniverse_id: @project_subject.zooniverse_id }
    end

    assert_redirected_to project_subject_path(assigns(:project_subject))
  end

  test "should show project_subject" do
    get :show, id: @project_subject
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project_subject
    assert_response :success
  end

  test "should update project_subject" do
    patch :update, id: @project_subject, project_subject: { priority: @project_subject.priority, properties: @project_subject.properties, seen_user_ids: @project_subject.seen_user_ids, zooniverse_id: @project_subject.zooniverse_id }
    assert_redirected_to project_subject_path(assigns(:project_subject))
  end

  test "should destroy project_subject" do
    assert_difference('ProjectSubject.count', -1) do
      delete :destroy, id: @project_subject
    end

    assert_redirected_to project_subjects_path
  end
end
