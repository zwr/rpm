Rails.application.routes.draw do
  get 'home/auth'
  root 'home#index'
end
