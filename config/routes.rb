Rails.application.routes.draw do
  
  get 'matches/report'

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  get '/auth/twitter/callback', to: 'sessions#twitter_login'
  delete '/logout', to: 'sessions#destroy'
  
  match 'select_title', to: 'characters#select_titles', via: [:get, :post]
  
  resources :users do
    resources :characters
  end
  resources :tournaments do
    resources :participants
    get 'reload', to: 'participants#reload'
    get 'randomize', to: 'participants#randomize'
    
    get 'start', to: 'tournaments#start'
    get 'reset', to: 'tournaments#reset'
    get 'finalize', to: 'tournaments#finalize'
    
    get 'report', to: 'matches#report'
    post 'update', to: 'matches#update'
  end
  
  resources :fileuploads, only: [:index, :create, :new]
end