Rails.application.routes.draw do
  get 'home/index'

  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :users, only: [:index, :show, :edit, :update, :destroy] do
    collection do
      get :register
    end
  end

  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  resources :lockers, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    member do
      patch :generate_password
    end
  end

  resources :managers do
    member do
      get :check_flash # Nueva ruta para verificar el flash
      post :check_connection
      patch :synchronize
    end
    resources :lockers, only: [:new, :create, :destroy, :update]
    member do
      get :synchronize # Route to synchronize a manager with ESP32
      post :assign_locker # Route to assign an existing locker
      delete :unassign_locker # Route to unassign an existing locker
    end
  end

  resources :managers do
    member do
      get :check_flash
    end
  end
  

   # Superuser dashboard
   resources :superuser, only: [:index] do
    collection do
      delete :destroy_user # Custom route to delete users (optional)
    end
  end
  resources :predictors
  resources :metrics, only: [:index]
  resources :lockers, only: [:index, :show] # Index and show for lockers outside the context of a manager

  get "up" => "rails/health#show", as: :rails_health_check
end
