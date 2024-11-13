Rails.application.routes.draw do
  get 'home/index'
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resource :user, only: [:edit, :update]

  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  # Declaración principal de lockers antes de las rutas anidadas
  resources :lockers, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    member do
      patch :generate_password  
    end
  end

  resources :managers do
    resources :lockers, only: [:new, :create]
    member do
      patch :synchronize # Ruta para la acción de sincronización
    end
  end

  resources :predictors 
  resources :metrics 
  resources :lockers, only: [:index, :show] # Index y show de lockers fuera de contexto de un manager

  get "up" => "rails/health#show", as: :rails_health_check
end
