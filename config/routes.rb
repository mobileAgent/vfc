ActionController::Routing::Routes.draw do |map|
  Clearance::Routes.draw(map)

  map.root :controller => "welcome"
  map.resources :places, :has_many => :speakers
  map.resources :speakers
  map.resources :audio_messages
  map.resources :languages, :has_many => :speakers
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
