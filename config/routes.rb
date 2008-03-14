include ActiveRecord::Validations::RoutingHelper

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'main'
  
  map.with_options :controller => 'articles' do |ar|
    ar.articles       'articles/by/:user_id',                              :action => 'index',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :user_id   => regex_for(:user, :nick) }
    ar.connect        'articles/by/:user_id', :action => 'create',
                                  :conditions =>   { :method => :post },
                                  :requirements => { :user_id   => regex_for(:user, :nick) }
    ar.new_article    'articles/by/:user_id/new', :action => 'new',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :user_id   => regex_for(:user, :nick) }
    ar.edit_article   ':year/:month/:day/:id/by/:user_id/edit',            :action => 'edit',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :year => /\d{4}/,
                                                     :month => /\d{1,2}/,
                                                     :day => /\d{1,2}/,
                                                     :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }
    ar.unpublish_article ':year/:month/:day/:id/by/:user_id/unpublish',    :action => 'unpublish',
                                  :conditions =>   { :method => :put },
                                  :requirements => { :year => /\d{4}/,
                                                     :month => /\d{1,2}/,
                                                     :day => /\d{1,2}/,
                                                     :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }
    ar.article        ':year/:month/:day/:id/by/:user_id',                 :action => 'show',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :year => /\d{4}/,
                                                     :month => /\d{1,2}/,
                                                     :day => /\d{1,2}/,
                                                     :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }                                                                                                          
    ar.connect        ':year/:month/:day/:id/by/:user_id',                 :action => 'update',
                                  :conditions =>   { :method => :put },
                                  :requirements => { :year => /\d{4}/,
                                                     :month => /\d{1,2}/,
                                                     :day => /\d{1,2}/,
                                                     :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }
    ar.connect        ':year/:month/:day/:id/by/:user_id',                 :action => 'destroy',
                                  :conditions =>   { :method => :delete },
                                  :requirements => { :year => /\d{4}/,
                                                     :month => /\d{1,2}/,
                                                     :day => /\d{1,2}/,
                                                     :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }
    ar.particle       'articles/:id/by/:user_id',                          :action => 'show',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }
    ar.particle       'articles/:id',                                      :action => 'show',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :id        => regex_for(:article, :permalink) }                    
    ar.edit_draft     'draft/:id/by/:user_id/edit',                        :action => 'edit',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }
    ar.draft          'draft/:id/by/:user_id',                             :action => 'show',
                                  :conditions =>   { :method => :get },
                                  :requirements => { :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }
    ar.connect        'draft/:id/by/:user_id',                      :action => 'update',
                                  :conditions =>   { :method => :put },
                                  :requirements => { :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }
    ar.publish_draft  'draft/:id/by/:user_id',                             :action => 'publish',
                                  :conditions =>   { :method => :put },
                                  :requirements => { :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }
    ar.connect        'draft/:id/by/:user_id',                             :action => 'destroy',
                                  :conditions =>   { :method => :delete },
                                  :requirements => { :id        => regex_for(:article, :permalink),
                                                     :user_id   => regex_for(:user, :nick) }
                                                    
  end
  
  map.with_options :controller => 'clips', :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                              :article_id => regex_for(:article, :permalink),
                                                              :user_id => regex_for(:user, :nick) } do |cl|
    # Article
    cl.article_clips ':year/:month/:day/:article_id/by/:user_id/clips', :action => 'index', :conditions => { :method => :get }
    cl.connect ':year/:month/:day/:article_id/by/:user_id/clips', :action => 'create', :conditions => { :method => :post }
    cl.new_article_clip ':year/:month/:day/:article_id/by/:user_id/clips/new', :action => 'new', :conditions => { :method => :get }
    cl.edit_article_clip ':year/:month/:day/:article_id/by/:user_id/clips/:id/edit', :action => 'edit', :conditions => { :method => :get }, :requirements => { :id => /\d+/ }
    cl.article_clip ':year/:month/:day/:article_id/by/:user_id/clips/:id', :action => 'show', :conditions => { :method => :get }, :requirements => { :id => /\d+/ }
    cl.connect ':year/:month/:day/:article_id/by/:user_id/clips/:id', :action => 'update', :conditions => { :method => :put }, :requirements => { :id => /\d+/ }
    cl.connect ':year/:month/:day/:article_id/by/:user_id/clips/:id', :action => 'destroy', :conditions => { :method => :delete }, :requirements => { :id => /\d+/ }
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
