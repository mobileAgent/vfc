ActionController::Routing::Routes.draw do |map|
  Clearance::Routes.draw(map)

  map.root :controller => "welcome"
  
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
