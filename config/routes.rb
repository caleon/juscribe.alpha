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
  
  # Notice that in the following, there aren't paths to Draft clips. That's because Drafts aren't public.
  # Intentionally done. This means I don't need to check #widgetable? on a draft. Routing handles that.
  map.with_options :controller => 'clips', :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                              :article_id => regex_for(:article, :permalink),
                                                              :user_id => regex_for(:user, :nick) } do |cl|
    # Article
    cl.article_clips ':year/:month/:day/:article_id/by/:user_id/clips', :action => 'index', :conditions => { :method => :get }
    cl.connect ':year/:month/:day/:article_id/by/:user_id/clips', :action => 'create', :conditions => { :method => :post }
    cl.new_article_clip ':year/:month/:day/:article_id/by/:user_id/clips/new', :action => 'new', :conditions => { :method => :get }
    cl.edit_article_clip ':year/:month/:day/:article_id/by/:user_id/clips/:id/edit', :action => 'edit', :conditions => { :method => :get }, :requirements => { :id => regex_for(:clip, :id) }
    cl.article_clip ':year/:month/:day/:article_id/by/:user_id/clips/:id', :action => 'show', :conditions => { :method => :get }, :requirements => { :id => regex_for(:clip, :id) }
    cl.connect ':year/:month/:day/:article_id/by/:user_id/clips/:id', :action => 'update', :conditions => { :method => :put }, :requirements => { :id => regex_for(:clip, :id) }
    cl.connect ':year/:month/:day/:article_id/by/:user_id/clips/:id', :action => 'destroy', :conditions => { :method => :delete }, :requirements => { :id => regex_for(:clip, :id) }
  end

  map.resources :messages, :requirements => { :id => regex_for(:message, :id) }
  
  map.resources :pictures, :requirements => { :id => regex_for(:picture, :id) } do |picture|
    picture.resources :clips, :requirements => { :picture_id => regex_for(:picture, :id),
                                                 :clip_id => regex_for(:clip, :id) }
  end

  map.resources :users,
                :member => { :friends => :get, :befriend => :put, :unfriend => :put,
                             :about => :get, :edit_password => :get,
                             :update_password => :put },
                :requirements => { :id => regex_for(:user, :nick) } do |user|
    user.resources :widgets, :member => { :place => :put, :unplace => :put },
                   :requirements => { :user_id => regex_for(:user, :nick), :id => regex_for(:widget, :id) }
    user.resources :clips, :requirements => { :user_id => regex_for(:user, :nick), :id => regex_for(:clip, :id) }
    user.resources :entries, :requirements => { :user_id => regex_for(:user, :nick), :id => regex_for(:entry, :id) }
    user.resources :events, :member => { :begin_event => :put, :end_event => :put },
                   :requirements => { :user_id => regex_for(:user, :nick), :id => regex_for(:event, :id) } do |event|
      event.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :event_id => regex_for(:event, :id),
                                                 :id => regex_for(:clip, :id) }
    end
    user.resources :pictures, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :id => regex_for(:picture, :id)}  do |picture|
      picture.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                                   :picture_id => regex_for(:picture, :id),
                                                   :id => regex_for(:clip, :id) }
    end
  end
      
  map.login 'login', :controller => 'users', :action => 'login'
  map.logout 'logout', :controller => 'users', :action => 'logout'
  map.mine 'mine', :controller => 'users', :action => 'mine'
  map.contents 'contents/:topic', :controller => 'main', :action => 'contents',
                                  :requirements => { :topic => regex_for(:main, :topic) }
  map.about 'about/:topic', :controller => 'main', :action => 'about', :topic => nil,
                            :requirements => { :topic => regex_for(:main, :topic) }
  map.help 'help/:topic', :controller => 'main', :action => 'help', :topic => nil,
                          :requirements => { :topic => regex_for(:main, :topic) }
  map.copyright 'copyright', :controller => 'main', :action => 'copyright'

  # Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
