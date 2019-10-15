Rails.application.routes.draw do
  
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  match 'select_title', to: 'characters#select_titles', via: [:get, :post]
  
  resources :users do
    resources :characters
  end
  resources :tournaments do
    resources :participants
  end
  
  resources :fileuploads, only: [:index, :create, :new]
end