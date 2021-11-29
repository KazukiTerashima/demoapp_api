Rails.application.routes.draw do
  root 'api/v1/index'
  namespace :api do
    namespace :v1 do
      resources :hello, only:[:index]
    end
  end
end
