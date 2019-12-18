class HomeController < ApplicationController
  def index
    if current_candidate.present?
      @profile = Profile.find_by(candidate_id: current_candidate.id)

      if @profile.nil?
        flash[:alert] = 'É necessario criar um perfil para se inscrever em qualquer vaga'
        redirect_to new_profile_path
      else 
        if !@profile.profile_is_complete?
          flash[:alert] = 'É necessario completar o perfil para se inscrever em qualquer vaga'
          redirect_to edit_profile_path(@profile)
        end
      end      
    end
  end
end
