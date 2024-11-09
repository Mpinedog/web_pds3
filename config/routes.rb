Rails.application.routes.draw do
  get 'home/index'
  devise_for :usuarios, controllers: {
    registrations: "usuarios/registrations",
    sessions: "usuarios/sessions",
    omniauth_callbacks: "usuarios/omniauth_callbacks"
  }

  resource :usuario, only: [:edit, :update]

  devise_scope :usuario do
    authenticated :usuario do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  # Declaración principal de casilleros antes de las rutas anidadas
  resources :casilleros, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    member do
      patch :generar_contrasena  
    end
  end

  resources :controladores do
    resources :casilleros, only: [:new, :create]
    member do
      patch :sincronizar # Ruta para la acción de sincronización
    end
  end

  resources :metricas
  resources :modelos, only: [:index, :show, :new, :create]

  get "up" => "rails/health#show", as: :rails_health_check
end
