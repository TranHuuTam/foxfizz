Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }
  
  mount Commontator::Engine => '/commontator'

  root "market#index"
  
  get "/search" => "main#search"
  get "/about" => "main#about"
  get "/help" => "main#help"

  # Admin namespace
  namespace :admin do
    root 'application#index', as: :root

    resources :users, only: [:index] do
      member do
        patch :change_role
      end

      collection do
        get :show_chart
      end
    end

    resources :posts, only: [:index] do
      get :show_chart, on: :collection
    end

    resources :categories, except: [:show]

    resources :settings, except: [:show] do
      collection do
        delete :clean_junk_tags
        delete :clean_junk_attachments
        post :send_notifications
        patch :update_access_token
      end
    end
  end

  get '/notifications', to: "users#notifications"
  get '/favorite_posts', to: "users#favorite_posts"

  resources :posts, except: [:index] do
    member do
      patch :favorite
      patch :mark_as_sold
      patch :report
    end
  end

  post :attachments, to: "attachments#create"
  patch :attachments, to: "attachments#create"

  resources :notifications, only: [:destroy] do
    collection do
      patch :mark_all_as_read
    end
    
    member do
      patch :mark_toggle_status
    end
  end

  resources :categories, only: [:show]

  get '/:username', to: "users#profile", as: :user_profile

  get '/:username/posts', to: "posts#index", as: :user_posts

  resources :users, only: [:show, :edit, :update] do
    member do
      get :edit_avatar
    end
  end

  resources :profiles, only: :update
end
