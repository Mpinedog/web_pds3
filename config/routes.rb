Rails.application.routes.draw do
  # Devise configuration for users
  devise_for :usuarios, controllers: {
    registrations: "usuarios/registrations",
    sessions: "usuarios/sessions",
    omniauth_callbacks: "usuarios/omniauth_callbacks"
  }

  #OAuth configuration for Google
  

  # Root paths for authenticated and unauthenticated users
  devise_scope :usuario do
    authenticated :usuario do
      root 'controladores#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  # Standard configuration for controladores resource
  resources :controladores, only: [:index, :new, :create, :show]

  # Other resources
  resources :modelos, only: [:index, :show, :new, :create]
  resources :casilleros, only: [:index, :show, :new, :create]

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
