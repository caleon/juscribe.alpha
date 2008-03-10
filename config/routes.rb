ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'main'

  map.show_article 'users/:user_id/:year/:month/:date/:id/:action', :controller => 'articles', :action => 'show',
                        :requirements => { :user_id => /[a-z][_a-z0-9]+/, :year => /\d{4}/, :month => /\d{2}/, :day => /\d{2}/ }
  #map.resources :articles do |article|
  #  article.resources :clips
  #end
  #map.resources :widgets, :controller => 'clips'
  map.resources :events, :member => { :begin_event => :put, :end_event => :put } do |event|
    event.resources :clips
  end

  map.resources :messages, :member => { :send => :put } # Check that model is clippable
  
  map.resources :pictures do |picture|
    picture.resources :clips
  end

  map.resources :users,
                :member => { :friends => :get, :befriend => :put, :unfriend => :put, :about => :get,
                             :edit_password => :get, :update_password => :put } do |user|
    user.resources :widgets, :member => { :place => :put, :unplace => :put }
    user.resources :clips
  end
    
  map.login 'login', :controller => 'users', :action => 'login'
  map.logout 'logout', :controller => 'users', :action => 'logout'
  map.mine 'mine', :controller => 'users', :action => 'mine'
  map.contents 'contents/:topic', :controller => 'main', :action => 'contents', :topic => nil
  map.help 'help/:topic', :controller => 'main', :action => 'help', :topic => nil
  map.copyright 'copyright', :controller => 'main', :action => 'copyright'

  # Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
