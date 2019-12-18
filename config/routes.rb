Rails.application.routes.draw do
  devise_for :candidates
  devise_for :headhunters
  
  root 'home#index'  

  resources :job_vacancies, only: [:index,:create,:new,:show]
  resources :profiles, only: [:show, :new, :create, :edit, :update]
end
