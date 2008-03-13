include ActiveRecord::Validations::RoutingHelper

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'main'
  
  map.with_options :controller => 'articles' do |ar|
    ar.articles       'articles/by/:nick',                              :action => 'index',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :nick      => regex_for(:user, :nick) }
    ar.connect        'articles/by/:nick', :action => 'create',
                                  :conditions =>   { :method => :post }
    ar.new_article    'articles/by/:nick/new', :action => 'new',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :nick      => regex_for(:user, :nick) }
    ar.edit_article   ':year/:month/:day/:permalink/by/:nick/edit',     :action => 'edit',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :year => /\d{4}/,
                                                     :month => /\d{1,2}/,
                                                     :day => /\d{1,2}/,
                                                     :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }
    ar.unpublish_article ':year/:month/:day/:permalink/by/:nick/unpublish',:action => 'unpublish',
                                  :conditions =>   { :method => :put },
                                  :requirements => { :year => /\d{4}/,
                                                     :month => /\d{1,2}/,
                                                     :day => /\d{1,2}/,
                                                     :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }
    ar.article        ':year/:month/:day/:permalink/by/:nick',          :action => 'show',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :year => /\d{4}/,
                                                     :month => /\d{1,2}/,
                                                     :day => /\d{1,2}/,
                                                     :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }                                                                                                          
    ar.connect        ':year/:month/:day/:permalink/by/:nick',          :action => 'update',
                                  :conditions =>   { :method => :put },
                                  :requirements => { :year => /\d{4}/,
                                                     :month => /\d{1,2}/,
                                                     :day => /\d{1,2}/,
                                                     :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }
    ar.connect        ':year/:month/:day/:permalink/by/:nick',          :action => 'destroy',
                                  :conditions =>   { :method => :delete },
                                  :requirements => { :year => /\d{4}/,
                                                     :month => /\d{1,2}/,
                                                     :day => /\d{1,2}/,
                                                     :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }
    ar.particle       'articles/:permalink/by/:nick',                   :action => 'show',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }
    ar.particle       'articles/:permalink',                            :action => 'show',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :permalink => regex_for(:article, :permalink) }                    
    ar.edit_draft     'draft/:permalink/by/:nick/edit',                 :action => 'edit',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }
    ar.draft          'draft/:permalink/by/:nick',                      :action => 'show',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }
    ar.connect        'draft/:permalink/by/:nick',                      :action => 'update',
                                  :conditions =>   { :method => :put },
                                  :requirements => { :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }
    ar.publish_draft  'draft/:permalink/by/:nick',                      :action => 'publish',
                                  :conditions =>   { :method => :put },
                                  :requirements => { :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }
    ar.connect        'draft/:permalink/by/:nick',                      :action => 'destroy',
                                  :conditions =>   { :method => :delete },
                                  :requirements => { :permalink => regex_for(:article, :permalink),
                                                     :nick      => regex_for(:user, :nick) }
                                                    
  end

  map.resources :messages
  
  map.resources(:pictures) {|picture| picture.resources :clips }

  map.resources :users,
                :member => { :friends => :get, :befriend => :put, :unfriend => :put,
                             :about => :get, :edit_password => :get,
                             :update_password => :put },
                :requirements => { :id => regex_for(:user, :nick) } do |user|
    user.resources :widgets, :member => { :place => :put, :unplace => :put }
    user.resources :clips
    user.resources :entries
    user.resources :events, :member => { :begin_event => :put, :end_event => :put } do |event|
      event.resources :clips
    end
    user.resources(:pictures) {|picture| picture.resources :clips }
  end
      
  map.login 'login', :controller => 'users', :action => 'login'
  map.logout 'logout', :controller => 'users', :action => 'logout'
  map.mine 'mine', :controller => 'users', :action => 'mine'
  map.contents 'contents/:topic', :controller => 'main', :action => 'contents', :topic => nil
  map.about 'about/:topic', :controller => 'main', :action => 'about', :topic => nil
  map.help 'help/:topic', :controller => 'main', :action => 'help', :topic => nil
  map.copyright 'copyright', :controller => 'main', :action => 'copyright'

  # Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
