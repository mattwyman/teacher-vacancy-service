class HiringStaff::Vacancies::CandidateSpecificationController < HiringStaff::Vacancies::ApplicationController
  before_action :school, :redirect_unless_vacancy_session_id, only: %i[new create]

  def new
    redirect_to job_specification_school_vacancy_path(school_id: school.id) unless session_vacancy_id

    @candidate_specification_form = ::CandidateSpecificationForm.new(session[:vacancy_attributes])
    @candidate_specification_form.valid? if %i[step_2 review].include?(session[:current_step])
  end

  def create
    @candidate_specification_form = CandidateSpecificationForm.new(candidate_specification_form)
    store_vacancy_attributes(@candidate_specification_form.vacancy.attributes.compact!)

    if @candidate_specification_form.valid?
      vacancy = update_vacancy(candidate_specification_form)
      return redirect_to_next_step(vacancy)
    end

    session[:current_step] = :step_2 unless session[:current_step].eql?(:review)
    redirect_to candidate_specification_school_vacancy_path(school_id: @school.id)
  end

  def edit
    vacancy = school.vacancies.published.find(vacancy_id)

    @candidate_specification_form = CandidateSpecificationForm.new(vacancy.attributes)
    @candidate_specification_form.valid?
  end

  def update
    vacancy = school.vacancies.published.find(vacancy_id)
    @candidate_specification_form = CandidateSpecificationForm.new(candidate_specification_form)
    @candidate_specification_form.id = vacancy.id

    if @candidate_specification_form.valid?
      update_vacancy(candidate_specification_form, vacancy)
      redirect_to edit_school_vacancy_path(school, vacancy.id), notice: I18n.t('messages.vacancies.updated')
    else
      render 'edit'
    end
  end

  private

  def candidate_specification_form
    params.require(:candidate_specification_form).permit(:education, :qualifications, :experience)
  end

  def next_step
    application_details_school_vacancy_path(school_id: school.id)
  end
end
