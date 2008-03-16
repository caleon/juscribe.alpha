include ActiveRecord::Validations::RoutingHelper

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'main'
  
  map.with_options :controller => 'articles', :requirements => { :user_id => regex_for(:user, :nick) } do |ar|
    ar.articles 'articles/by/:user_id', :action => 'index', :conditions => { :method => :get }
    ar.formatted_articles 'articles/by/:user_id.:format', :action => 'index', :conditions => { :method => :get }
    ar.connect 'articles/by/:user_id', :action => 'create', :conditions => { :method => :post }
    ar.connect 'articles/by/:user_id.:format', :action => 'create', :conditions => { :method => :post }
    ar.new_article 'articles/by/:user_id/new', :action => 'new', :conditions => { :method => :get }
    ar.formatted_new_article 'articles/by/:user_id/new.:format', :action => 'new', :conditions => { :method => :get }
    ar.with_options :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :id => regex_for(:article, :permalink) } do |arpm|
      arpm.edit_article ':year/:month/:day/:id/by/:user_id/edit', :action => 'edit',
                                    :conditions =>   { :method => :get }
      arpm.formatted_edit_article ':year/:month/:day/:id/by/:user_id/edit.:format', :action => 'edit',
                                    :conditions =>   { :method => :get }
      arpm.unpublish_article ':year/:month/:day/:id/by/:user_id/unpublish',    :action => 'unpublish',
                                    :conditions =>   { :method => :put }
      arpm.formatted_unpublish_article ':year/:month/:day/:id/by/:user_id/unpublish.:format', :action => 'unpublish',
                                    :conditions =>   { :method => :put }
      arpm.article        ':year/:month/:day/:id/by/:user_id',                 :action => 'show',
                                    :conditions =>   { :method => :get }                                                                                                      
      arpm.formatted_article ':year/:month/:day/:id/by/:user_id',              :action => 'show',
                                    :conditions =>   { :method => :get }
      arpm.connect        ':year/:month/:day/:id/by/:user_id',                 :action => 'update',
                                    :conditions =>   { :method => :put }
      arpm.connect        ':year/:month/:day/:id/by/:user_id.:format',         :action => 'update',
                                    :conditions =>   { :method => :put }
      arpm.connect        ':year/:month/:day/:id/by/:user_id',                 :action => 'destroy',
                                    :conditions =>   { :method => :delete }
      arpm.connect        ':year/:month/:day/:id/by/:user_id.:format',         :action => 'destroy',
                                    :conditions =>   { :method => :delete }
    end
    ar.with_options :requirements => { :id => regex_for(:article, :permalink) } do |par|
      par.user_particles            'articles/:id/by/:user_id',               :action => 'show',
                                    :conditions =>   { :method => :get }
      par.formatted_user_particles  'articles/:id/by/:user_id.:format',       :action => 'show',
                                    :conditions =>   { :method => :get }
      par.particles                 'articles/:id',                           :action => 'show',
                                    :conditions =>   { :method => :get }                  
      par.formatted_particles       'articles/:id.:format',                   :action => 'show',
                                    :conditions =>   { :method => :get }
      par.edit_draft                'draft/:id/by/:user_id/edit',             :action => 'edit',
                                    :conditions =>   { :method => :get }
      par.formatted_edit_draft      'draft/:id/by/:user_id/edit.:format',     :action => 'edit',
                                    :conditions =>   { :method => :get }
      par.publish_draft             'draft/:id/by/:user_id/publish',          :action => 'publish',
                                    :conditions =>   { :method => :put }
      par.formatted_publish_draft   'draft/:id/by/:user_id/publish.:format',  :action => 'publish',
                                    :conditions =>   { :method => :put }
      par.draft                     'draft/:id/by/:user_id',                  :action => 'show',
                                    :conditions =>   { :method => :get }
      par.foramtted_draft           'draft/:id/by/:user_id.:format',          :action => 'show',
                                    :conditions =>   { :method => :get }
      par.connect                   'draft/:id/by/:user_id',                  :action => 'update',
                                    :conditions =>   { :method => :put }
      par.connect                   'draft/:id/by/:user_id.:format',          :action => 'update',
                                    :conditions =>   { :method => :put }
      par.connect                   'draft/:id/by/:user_id',                  :action => 'destroy',
                                    :conditions =>   { :method => :delete }
      par.connect                   'draft/:id/by/:user_id.:format',          :action => 'destroy',
                                    :conditions =>   { :method => :delete }
    end
  end
  
  ### A R T I C L E   S U B S E T S ##
  # Notice that in the article_clips routes, there aren't paths to Draft clips. That's because
  # Drafts aren't public. Intentionally done. This means I don't need to check #widgetable? on
  # a draft. Routing handles that.
  map.with_options :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :article_id => regex_for(:article, :permalink), :user_id => regex_for(:user, :nick) } do |ars|
    # Article -> Clips
    ars.with_options :controller => 'clips' do |cl|
      # Article clips
      cl.article_clips ':year/:month/:day/:article_id/by/:user_id/clips', :action => 'index', :conditions => { :method => :get }
      cl.connect ':year/:month/:day/:article_id/by/:user_id/clips', :action => 'create', :conditions => { :method => :post }
      cl.new_article_clip ':year/:month/:day/:article_id/by/:user_id/clips/new', :action => 'new', :conditions => { :method => :get }
      cl.edit_article_clip ':year/:month/:day/:article_id/by/:user_id/clips/:id/edit', :action => 'edit', :conditions => { :method => :get }, :requirements => { :id => regex_for(:clip, :id) }
      cl.article_clip ':year/:month/:day/:article_id/by/:user_id/clips/:id', :action => 'show', :conditions => { :method => :get }, :requirements => { :id => regex_for(:clip, :id) }
      cl.connect ':year/:month/:day/:article_id/by/:user_id/clips/:id', :action => 'update', :conditions => { :method => :put }, :requirements => { :id => regex_for(:clip, :id) }
      cl.connect ':year/:month/:day/:article_id/by/:user_id/clips/:id', :action => 'destroy', :conditions => { :method => :delete }, :requirements => { :id => regex_for(:clip, :id) }
    end
    # Article -> Comments
    ars.with_options :controller => 'comments' do |cm|
      cm.article_comments ':year/:month/:day/:article_id/by/:user_id/comments',
                          :action => 'index', :conditions => { :method => :get }
      cm.connect ':year/:month/:day/:article_id/by/:user_id/comments',
                  :action => 'create', :conditions => { :method => :post }
      cm.new_article_comment ':year/:month/:day/:article_id/by/:user_id/comments/new',
                             :action => 'new', :conditions => { :method => :get }
      cm.edit_article_comment ':year/:month/:day/:article_id/by/:user_id/comments/:id/edit',
                              :action => 'edit', :conditions => { :method => :get },
                              :requirements => { :id => regex_for(:comment, :id) }
      cm.article_comment ':year/:month/:day/:article_id/by/:user_id/comments/:id',
                         :action => 'show', :conditions => { :method => :get },
                         :requirements => { :id => regex_for(:comment, :id) }
      cm.connect ':year/:month/:day/:article_id/by/:user_id/comments/:id',
                 :action => 'update', :conditions => { :method => :put },
                 :requirements => { :id => regex_for(:comment, :id) }
      cm.connect ':year/:month/:day/:article_id/by/:user_id/comments/:id',
                 :action => 'destroy', :conditions => { :method => :delete },
                 :requirements => { :id => regex_for(:comment, :id) }
    end
    # Article -> Permissions
    ars.with_options :controller => 'permissions' do |pm|
      pm.connect ':year/:month/:day/:article_id/by/:user_id/permission',
                 :action => 'create', :conditions => { :method => :post }
      pm.new_article_permission ':year/:month/:day/:article_id/by/:user_id/permission/new',
                 :action => 'new', :conditions => { :method => :get }
      pm.edit_article_permission ':year/:month/:day/:article_id/by/:user_id/permission/:id/edit',
                 :action => 'edit', :conditions => { :method => :get },
                 :requirements => { :id => regex_for(:permission, :id) }
      pm.article_permission ':year/:month/:day/:article_id/by/:user_id/permission/:id',
                 :action => 'show', :conditions => { :method => :get },
                 :requirements => { :id => regex_for(:permission, :id) }
      pm.connect ':year/:month/:day/:article_id/by/:user_id/permission/:id',
                 :action => 'update', :conditions => { :method => :put },
                 :requirements => { :id => regex_for(:permission, :id) }
      pm.connect ':year/:month/:day/:article_id/by/:user_id/permission/:id',
                 :action => 'destroy', :conditions => { :method => :delete },
                 :requirements => { :id => regex_for(:permission, :id) }
    end
  end

  map.resources :messages, :requirements => { :id => regex_for(:message, :id) }
  map.resources :pictures, :requirements => { :id => regex_for(:picture, :id) } do |picture|
    picture.resources :clips, :requirements => { :picture_id => regex_for(:picture, :id),
                                                 :id => regex_for(:clip, :id) }
    picture.resources :comments, :requirements => { :picture_id => regex_for(:picture, :id),
                                                    :id => regex_for(:comment, :id) }
    picture.resource :permission, :requirements => { :picture_id => regex_for(:picture, :id),
                                                     :id => regex_for(:permission, :id) }
  end
  map.resources :users, :member => { :friends => :get, :befriend => :put, :unfriend => :put,
                        :about => :get, :edit_password => :get, :update_password => :put },
                        :requirements => { :id => regex_for(:user, :nick) } do |user|
    user.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                              :id => regex_for(:clip, :id) }
    user.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :id => regex_for(:comment, :id) }
    user.resources :entries, :requirements => { :user_id => regex_for(:user, :nick),
                                                :id => regex_for(:entry, :id) } do |entry|
      entry.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :entry_id => regex_for(:entry, :id),
                                                 :id => regex_for(:clip, :id) }
      entry.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                    :entry_id => regex_for(:entry, :id),
                                                    :id => regex_for(:comment, :id) }
      entry.resource :permission, :requirements => { :user_id => regex_for(:user, :nick),
                                                     :entry_id => regex_for(:entry, :id),
                                                     :id => regex_for(:permission, :id) }
    end
    user.resources :events, :member => { :begin_event => :put, :end_event => :put }, :requirements => { :user_id => regex_for(:user, :nick), :id => regex_for(:event, :id) } do |event|
      event.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :event_id => regex_for(:event, :id),
                                                 :id => regex_for(:clip, :id) }
      event.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                    :event_id => regex_for(:event, :id),
                                                    :id => regex_for(:comment, :id) }
      event.resource :permission, :requirements => { :user_id => regex_for(:user, :nick),
                                                     :event_id => regex_for(:event, :id),
                                                     :id => regex_for(:permission, :id) }
    end
    user.resources :galleries, :requirements => { :id => regex_for(:gallery, :id) }
    user.resource :permission, :requirements => { :user_id => regex_for(:user, :nick),
                                                   :id => regex_for(:permission, :id) }
    user.resources :widgets, :member => { :place => :put, :unplace => :put },
                   :requirements => { :user_id => regex_for(:user, :nick),
                                      :id => regex_for(:widget, :id) }
  end
      
  map.login 'login', :controller => 'users', :action => 'login'
  map.formatted_login 'login.:format', :controller => 'users', :action => 'login'
  map.logout 'logout', :controller => 'users', :action => 'logout'
  map.formatted_logout 'logout.:format', :controller => 'users', :action => 'logout'
  map.mine 'mine', :controller => 'users', :action => 'mine'
  map.formatted_mine 'mine.:format', :controller => 'users', :action => 'mine'
  map.contents 'contents/:topic', :controller => 'main', :action => 'contents', :topic => nil,
                                  :requirements => { :topic => regex_for(:main, :topic) }
  map.formatted_contents 'contents/:topic.:format', :controller => 'main', :action => 'contents',
                                  :requirements => { :topic => regex_for(:main, :topic) }
  map.about 'about/:topic', :controller => 'main', :action => 'about', :topic => nil,
                            :requirements => { :topic => regex_for(:main, :topic) }
  map.formatted_about 'about/:topic.:format', :controller => 'main', :action => 'about',
                                              :requirements => { :topic => regex_for(:main, :topic) }
  map.help 'help/:topic', :controller => 'main', :action => 'help', :topic => nil,
                          :requirements => { :topic => regex_for(:main, :topic) }
  map.formatted_help 'help/:topic.:format', :controller => 'main', :action => 'help',
                                           :requirements => { :topic => regex_for(:main, :topic) }
  map.copyright 'copyright', :controller => 'main', :action => 'copyright'
  map.formatted_copyright 'copyright.:format', :controller => 'main', :action => 'copyright'

  # Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
