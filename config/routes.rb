Jusk::Application.routes.draw do
  resources :games do
    resources :results, only: [:create, :destroy, :new] do
      post :slack, on: :collection
    end
    resources :ratings, only: [:index]
  end

  resources :players do
    resources :games, only: [:show], controller: 'player_games'
  end

  get '/dashboard' => 'dashboard#show', as: :dashboard
  root to: 'games#first'
end
