class ProjectSubjectsController < ApplicationController
  before_action :set_project_subject, only: [:show, :edit, :update, :destroy]

  # GET /project_subjects
  def index
    @project_subjects = ProjectSubject.all
  end

  # GET /project_subjects/1
  def show
  end

  # GET /project_subjects/new
  def new
    @project_subject = ProjectSubject.new
  end

  # GET /project_subjects/1/edit
  def edit
  end

  # POST /project_subjects
  def create
    @project_subject = ProjectSubject.new(project_subject_params)

    if @project_subject.save
      redirect_to @project_subject, notice: 'Project subject was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /project_subjects/1
  def update
    if @project_subject.update(project_subject_params)
      redirect_to @project_subject, notice: 'Project subject was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /project_subjects/1
  def destroy
    @project_subject.destroy
    redirect_to project_subjects_url, notice: 'Project subject was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project_subject
      @project_subject = ProjectSubject.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def project_subject_params
      params.require(:project_subject).permit(:zooniverse_id, :priority, :seen_user_ids, :properties)
    end
end
