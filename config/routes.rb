ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => 'users'
  # See how all your routes lay out with "rake routes"
  
  map.resources :users,
                :member => { :friends => :get, :befriend => :any, :unfriend => :any, :about => :get, :edit_password => :get }
  map.resources :messages
  
  map.resources :articles
  
  map.resources :pictures
  
  map.resources :search

  map.login 'login', :controller => 'users', :action => 'login'
  map.logout 'logout', :controller => 'users', :action => 'logout'
  map.mine 'mine', :controller => 'users', :action => 'mine'
  map.mailbox 'mailbox', :controller => 'users', :action => 'mailbox'
  map.contents 'contents/:topic', :controller => 'main', :action => 'contents', :topic => nil
  map.help 'help/:topic', :controller => 'main', :action => 'help', :topic => nil
  map.copyright 'copyright', :controller => 'main', :action => 'copyright'
  #map.user 'user/view/:id', :controller => 'users', :action => 'show'  

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
