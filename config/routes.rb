Rails.application.routes.draw do
  root 'spa#index'

  post :parse, controller: :spa
end
