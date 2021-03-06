class JobVacanciesController < ApplicationController

    before_action :authenticate_candidate!, only: [:apply,:search]
    before_action :validate_profile!, only: [:index, :apply, :search]
    
    before_action :authenticate_headhunter!, only: [:new,:create, :candidate_list, :closes]
    
    before_action :authenticate_user!

    def index
        if current_headhunter.present?
            @job_vacancies = JobVacancy.where(headhunter_id: current_headhunter.id)
        else
            @job_vacancies = JobVacancy.where("limit_date > ?", Date.current).open
        end      
    end

    def show
        @job_vacancy = JobVacancy.find(params[:id])

        if current_candidate.present?         
            @registered = Registered.new
        else
            @registereds = Registered.where(job_vacancy_id: @job_vacancy).accept_proposal
        end
    end

    def new
        @job_vacancy = JobVacancy.new
    end

    def create
        @job_vacancy = JobVacancy.new(params_job_vacancy)
        @job_vacancy.headhunter_id = current_headhunter.id
        if @job_vacancy.save()
            flash[:notice] = "Vaga criada com sucesso."
            redirect_to @job_vacancy
        else
            render :new
        end
    end

    def search
        @job_vacancies = JobVacancy.where("limit_date > ?", Date.current).open
        @job_vacancies = @job_vacancies.where("title like ? or vacancy_description like ?",
                                              "%#{params[:q]}%", "%#{params[:q]}%") unless params[:q].blank?
        @job_vacancies = @job_vacancies.where(level: params[:levels]) unless params[:levels].blank?
        @job_vacancies = @job_vacancies.where("minimum_wage >= ?", "#{params[:minimun]}") unless params[:minimun].blank?

        render :index
    end

    def apply
        @job_vacancy = JobVacancy.find(params[:id])
        @registered = Registered.new(candidate_id: current_candidate.id, job_vacancy_id: @job_vacancy.id, 
                                     registered_justification: params[:registered][:registered_justification])
        if @registered.save
            flash[:notice] = "Você se escreveu para a vaga: #{@job_vacancy.title}, com sucesso"
            redirect_to @job_vacancy
        else
            flash[:alert] = @registered.errors.full_messages.first
            redirect_to @job_vacancy
        end
    end

    def candidate_list
        @job_vacancy = JobVacancy.find(params[:id])
        @registereds = @job_vacancy.registereds.where('registereds.status <> 5')
        @favorits_registereds = @registereds.checked
        @canceled_registereds = @job_vacancy.registereds.excluded
    end

    def closes
        @job_vacancy = JobVacancy.find(params[:id])

        registereds = Registered.where(status: [:in_progress, :proposal, :reject_proposal]).where(job_vacancy_id: @job_vacancy.id)
        registereds.each do |registered|
            registered.closed!

            if registered.proposal.present?
                registered.proposal.destroy
            end
        end

        @job_vacancy.closed!

        redirect_to @job_vacancy
    end

    private

    def params_job_vacancy
        params.require(:job_vacancy).permit(:title, :vacancy_description, :ability_description,
                                            :maximum_wage, :minimum_wage, :level, :limit_date,
                                            :region)
    end

end