Vfc::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  resources :speakers
  resources :audio_messages
  resources :hymns
  resources :tags
  resources :places, :has_many => :speakers
  resources :languages, :has_many => :speakers
  resources :videos
  resources :writings
  resources :notes
  
  root :to => "welcome#index"

  get '/favicon.ico' => 'welcome#favicon'
  get '/login' => 'login#login'
  get '/featured' => 'motms#index'
  get '/speaker/name/:id' => 'speakers#name'
  get '/places/:id/speakers' => 'places#speakers'
  get '/languages/:id/speakers' => 'languages#speakers'
  get '/speakers/:id/place/:place_id' => 'speakers#place'
  get '/speakers/:id/language/:language_id' => 'speakers#language'
  get '/player/:id/:time_offset' => 'welcome#player'
  get '/notes/audio/:id/note/:note_id' => 'notes#audio'

  # Line up with stuff from the old static site
  get '/VFC-GOLD/:speaker_name/:filename' => 'audio_messages#gold'
  get '/about' => 'welcome#about'
  get '/contact' => 'welcome#contact'
  get '/order' => 'welcome#index'
  get '/friends' => 'welcome#index'
  get '/index.shtml' => 'welcome#index'
  get '/index.html' => 'welcome#index'

  # Errors 
  get '/404', :to => 'errors#not_found'
  get '/500', :to => 'errors#error'

  # Default route
  match ':controller(/:action(/:id(.:format)))', via: :get
  
end
