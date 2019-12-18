require 'rails_helper'

feature 'Candidate register a profile' do
    scenario 'successufully' do
        candidate = Candidate.create!(email: 'candidate@teste.com',
                                      password: '123teste')
        login_as(candidate, :scope => :candidate)

        visit root_path

        fill_in 'Nome completo', with: 'Fulano Siclano'
        fill_in 'Nome social', with: 'Siclano'
        fill_in 'Data de nascimento', with: '15/07/1989'
        fill_in 'Formação', with: 'Graduado em analise de sistema'
        fill_in 'Descrição', with: 'Busco oportunidade como programador'
        fill_in 'Experiência', with: 'Trabalho 2 anos na empresa X'
        
        click_on 'Salvar'

        expect(page).to have_content('Perfil concluido com sucesso')
    end

    scenario 'but incomplete profile' do
        candidate = Candidate.create!(email: 'candidate@teste.com',
                                      password: '123teste')
        login_as(candidate, :scope => :candidate)

        visit root_path

        fill_in 'Nome completo', with: 'Fulano Siclano'
        
        click_on 'Salvar'

        profile = Profile.last

        expect(page).to have_content('É necessario completar o perfil para se inscrever em qualquer vaga')
        expect(current_path).to eq(edit_profile_path(profile))
    end
end