Rails.application.routes.draw do
  get 'auth', to: 'home#auth'
  post 'logout', to: 'home#logout'
  root 'home#index'
end
