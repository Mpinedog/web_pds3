Rails.application.routes.draw do
  devise_for :usuarios, controllers: {
    registrations: "usuarios/registrations",
    sessions: "usuarios/sessions",
    omniauth_callbacks: "usuarios/omniauth_callbacks"
  }

  resource :usuario, only: [:edit, :update]

  devise_scope :usuario do
    authenticated :usuario do
      root 'controladores#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  # Rutas para controladores con opción de sincronización y casilleros anidados
  resources :controladores, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    member do
      patch :sincronizar # Ruta para la acción de sincronización
    end
    resources :casilleros, only: [:new, :create] # Casilleros anidados en controladores
  end

  resources :modelos
  resources :casilleros, only: [:index, :show] # Index y show de casilleros fuera de contexto de un controlador

  get "up" => "rails/health#show", as: :rails_health_check
end
