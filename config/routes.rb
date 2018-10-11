Rails.application.routes.draw do
  # resources :users do
  #   member do
  #     get :add_comic
  #   end
  # end
  #
  # resources :comics
  # resources :sites

  post '/callback', to: 'webhook#callback'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
