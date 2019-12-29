class ProposalsController < ApplicationController

    before_action :authenticate_headhunter!, only: [:new,:create]

    def index

        if current_candidate.present?
            @proposals = Proposal.joins(:registered).where('registereds.candidate_id = ?', current_candidate.id)
        end
            
    end

    def show
        @proposal = Proposal.find(params[:id])
        @job_vacancy = @proposal.registered.job_vacancy
        @profile = @proposal.registered.candidate.profile
    end




    def new
        @registered = Registered.find(params[:id])
        @proposal = @registered.build_proposal

        @minimum = @registered.job_vacancy.minimum_wage
        @maximum = @registered.job_vacancy.maximum_wage
    end

    def create
        @registered = Registered.find(params[:id])
        @proposal = @registered.build_proposal(params_proposal)

        if @proposal.save
            registered.proposal!

            flash[:notice] = "Proposta enviada ao candidato #{@registered.candidate.profile.name} com sucesso"

            redirect_to candidate_list_job_vacancy_path(@registered.job_vacancy.id)
        else 
            render :new
        end        
    end

    private 

    def params_proposal
        params.require(:proposal).permit(:salary, :start_date, :limit_feedback_date, :benefits, :note)
    end

end