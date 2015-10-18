Rails.application.routes.draw do
  devise_for :users

  resources :charges
  resources :growth

  resources :tasks do
    member do
      get :follow
      get :unfollow
    end
  end

  get '/scheduler', to: 'scheduler#index'
  root "tasks#index"
end
