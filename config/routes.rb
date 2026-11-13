Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ], path: "acesso", controllers: { sessions: "users/sessions", passwords: "users/passwords", omniauth_callbacks: "users/omniauth_callbacks" }
  root "pages#home"
  get "escola", to: "pages#school"
  get "agenda", to: "pages#agenda"
  resources :articles, path: "noticias", only: [ :index, :show ] do
    get "capa", on: :member, to: "covers#show", as: :cover
  end
  namespace :admin do
    root "dashboard#index"
    resources :articles, except: :show do
      post :preview, on: :collection
      patch :publish, on: :member
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
