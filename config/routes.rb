Rails.application.routes.draw do
  resources :emails, only: %i(index create) do
    collection do
      post :hook
      get :opened
      get :clicked
    end
  end

  root 'emails#index'
end
