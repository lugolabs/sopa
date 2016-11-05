Rails.application.routes.draw do
  resources :emails, only: :index do
    get :hook, on: :collection
  end

  root 'emails#index'
end
