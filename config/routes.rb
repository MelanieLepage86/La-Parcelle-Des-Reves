Rails.application.routes.draw do
  namespace :admin, path: '/parmatouze1317' do
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
    get 'dashboard/new_image', to: 'dashboard#new_image', as: 'new_image'
    post 'dashboard/create_image', to: 'dashboard#create_image', as: 'create_image'

    resources :orders, only: [:index, :update]
    resources :artworks, only: [] do
      patch :toggle_publish, on: :member
    end
  end

  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  get '/parmatouze1317', to: redirect('/users/sign_in')

  resources :artworks do
    collection do
      get :portfolio
      get :boutique
      get :prestations
    end
  end

  resources :orders, only: [:new, :create, :show]
  resources :contacts, only: [:new, :create]
  get '/page_daccueil', to: 'pages#accueil'
  get '/a_propos', to: 'pages#about'
  get '/payment_intent/:id', to: 'orders#payment_intent'
  post '/connect_stripe', to: 'stripe#connect', as: :connect_stripe
  get 'stripe/connect', to: 'stripe#connect'
  post '/add_to_cart', to: 'carts#add', as: :add_to_cart
  post 'remove_from_cart', to: 'carts#remove', as: 'remove_from_cart'
  get '/mentions', to: 'pages#mentions'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  resource :cart, only: [:show], path: '/panier' do
    post :checkout
  end

  resources :subscribers, only: [:create] do
    member do
      get :unsubscribe
    end
  end

  resources :newsletters, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    member do
      post :send_to_subscribers
      get :preview_email
    end
  end

  get '/artworks/:category/:sub_category', to: 'artworks#sub_category', as: 'artworks_category_sub_category'
end
