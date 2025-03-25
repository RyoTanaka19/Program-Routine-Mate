Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

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

    resources :study_logs, only: %i[index show new create edit update destroy] do
      collection do
        get "ranking"  # ランキングページを追加
      end

      resources :learning_comments, only: %i[create destroy edit update], shallow: true
      resource :like, only: %i[create destroy]  # もし「いいね」が単一ならこれでOK
      # 複数の「いいね」が必要な場合は、上記を次のように変更
      # resources :likes, only: %i[create destroy]
    end

    get "user/:id/badges", to: "users#badges", as: "user_badges"
    get "users/:id", to: "users#show", as: "users_profile"
    resources :proposals, only: %i[new create show index]
end
