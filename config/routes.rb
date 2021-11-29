Rails.application.routes.draw do
  root "hello#index"
  namespace :api do
    namespace :v1 do
      resources :hello, only:[:index]
    end
  end
end
