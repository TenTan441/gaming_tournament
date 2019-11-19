Rails.application.routes.draw do
  
  get 'matches/report'

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  get '/auth/twitter/callback', to: 'sessions#twitter_login'
  delete '/logout', to: 'sessions#destroy'
  
  
  
  resources :users do
    get 'characters/edit', to: 'characters#edit'
    put 'characters/update', to: 'characters#update'
    match 'characters/select_title', to: 'characters#select_titles', via: [:get, :post]
    resources :characters
    resources :messages
    
    get 'contact', to: 'users#contact'
    get 'title_character', to: 'users#title_character'
    post 'send_dm', to: 'users#send_dm'
  end
  resources :tournaments do
    delete 'participants/clear', to: 'participants#clear'
    resources :participants
    
    get 'reload', to: 'participants#reload'
    get 'randomize', to: 'participants#randomize'
    
    get 'start', to: 'tournaments#start'
    get 'reset', to: 'tournaments#reset'
    get 'finalize', to: 'tournaments#finalize'
    
    get 'report', to: 'matches#report'
    post 'update', to: 'matches#update'
    get 'reset_match', to: 'matches#reset'
  end
  
  resources :fileuploads, only: [:index, :create, :new]
end