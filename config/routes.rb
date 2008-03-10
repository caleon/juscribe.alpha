ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'users'

  map.resources :articles, :member => { :clip => :put, :unclip => :put }
  
  map.resources :events, :member => { :begin_event => :put, :end_event => :put, :clip => :put, :unclip => :put }

  map.resources :messages, :member => { :send => :put, :clip => :put, :unclip => :put }
  
  map.resources :pictures, :member => { :clip => :put, :unclip => :put}

  map.resources :users,
                :member => { :friends => :get, :befriend => :put, :unfriend => :put, :about => :get,
                             :edit_password => :get, :update_password => :put, :clip => :put, :unclip => :put } do |user|
    user.resources :widgets
  end
    
  map.login 'login', :controller => 'users', :action => 'login'
  map.logout 'logout', :controller => 'users', :action => 'logout'
  map.mine 'mine', :controller => 'users', :action => 'mine'
  map.mailbox 'mailbox', :controller => 'users', :action => 'mailbox'
  map.contents 'contents/:topic', :controller => 'main', :action => 'contents', :topic => nil
  map.help 'help/:topic', :controller => 'main', :action => 'help', :topic => nil
  map.copyright 'copyright', :controller => 'main', :action => 'copyright'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
