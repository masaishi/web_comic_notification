Rails.application.routes.draw do
  resources :users do
    member do
      get :bookmark
    end
  end

  resources :comics do
    member do
      get :bookmark
    end
  end
  resources :sites

  post '/callback', to: 'webhook#callback'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
