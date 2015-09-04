Rails.application.routes.draw do
  # agents
  devise_for :agents, :controllers => { :registrations => 'agents/registrations' }

  devise_scope :agent do
    get '/login' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
    post '/agents', to: 'agents/registrations#create'
  end

  resources :agents, :controller => "agents", except: [:create]

  # static_pages
  root to: 'static_pages#home'     
  get 'apps' => 'static_pages#apps'

  # employees
  get 'employees', to: 'employees#index'
  post 'submit', to: 'employees#submit'
end
