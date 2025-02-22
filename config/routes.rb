Rails.application.routes.draw do
  get "relationship/create"
  get "relationship/destroy"
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "static_pages/home"
    get "static_pages/help"

    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    resources :users do
      collection do
        get :tigers
      end
    end

    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    resources :account_activations, only: :edit

    get "password_reset/new"
    get "password_reset/edit"
    get "password_reset/create"
    get "password_reset/update"
    resources :password_resets, only: %i(new create edit update)

    resources :microposts, only: %i(create destroy)

    resources :relationships,only: %i(create destroy)
  end
end
