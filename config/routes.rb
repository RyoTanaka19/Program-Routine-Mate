require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }
  resources :users, only: [ :show ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  root "top_study_logs#top"
  resources :study_genres do
    resources :study_logs, only: %i[ index show new create edit update destroy ] do
      collection do
        get "ranking"  # ランキングページを追加
        get :autocomplete
      end
    end
  end

  match "/wp-admin/*path", to: proc { [ 404, {}, [ "" ] ] }, via: :all

    get "user/:id/badges", to: "users#badges", as: "user_badges"
    get "privacy", to: "static_pages#privacy"
    get "terms", to: "static_pages#terms"
    get "images/ogp.png", to: "images#ogp", as: "images_ogp"
    get "form", to: "static_pages#form"

    resources :suggests, only: %i[ new create show index destroy ]
    mount Sidekiq::Web => "/sidekiq"
    mount ActionCable.server => "/cable"

    resources :study_reminders, only: [ :index, :new, :create ] do
      collection do
        get "events", to: "study_reminders#events"
      end
    end

    resources :study_logs do
     collection do
      get :autocomplete
      get "ranking"
     end
      resources :learning_comments, only: %i[ create destroy edit update ], shallow: true
      resource :like, only: %i[ create destroy ]
    end
end
