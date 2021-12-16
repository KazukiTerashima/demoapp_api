Rails.application.routes.draw do
  # root "hello#index"
  namespace :api do
    namespace :v1 do
      resources :users, only:[:index]
    end
  end
end
