Rails.application.routes.draw do
  get 'auth', to: 'home#auth'
  get 'logout', to: 'home#logout'
  root 'home#index'
end
