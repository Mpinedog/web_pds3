Rails.application.routes.draw do
  get 'home/index'
  
  devise_for :usuarios, controllers: {
    registrations: "usuarios/registrations",
    sessions: "usuarios/sessions",
    omniauth_callbacks: "usuarios/omniauth_callbacks"
  }

  resources :usuarios, only: [:index, :show, :edit, :update, :destroy] do
    collection do
      get :registro 
    end
  end

  devise_scope :usuario do
    authenticated :usuario do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  resources :casilleros, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    member do
      patch :generar_contrasena
    end
  end

  resources :controladores do
    resources :casilleros, only: [:new, :create, :destroy, :update]
    member do
      get :sincronizar # Ruta para sincronizar un controlador con el ESP32
      post :asignar_casillero # Ruta para asignar un casillero existente
      delete :desasignar_casillero # Ruta para desasignar un casillero existente
    end
  end

  resources :superusuario, only: [:index]
  resources :modelos 
  resources :metricas, only: [:index]
  resources :casilleros, only: [:index, :show] # Index y show de casilleros fuera de contexto de un controlador


  get "up" => "rails/health#show", as: :rails_health_check
end
