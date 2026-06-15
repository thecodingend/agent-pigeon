Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  authenticated :user do
    root to: "email_connections#show", as: :authenticated_root
  end

  devise_scope :user do
    root to: redirect("/users/sign_in")
  end

  resources :agents do
    resources :threads, only: [ :index, :show ], controller: "agent_threads"
  end

  resource :email_connection, only: [ :show, :create, :update ] do
    post :check_dns
  end

  post "webhooks/resend", to: "resend_webhooks#create"

  resources :data_sources, only: [ :index ]
  resources :api_connectors, only: [ :new, :create, :destroy ]
  resources :web_connectors, only: [ :new, :create, :destroy ]

  get "up" => "rails/health#show", as: :rails_health_check
end
