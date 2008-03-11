require File.join(RAILS_ROOT,  'lib/active_record/validations/constants') unless Object.const_defined?(:REGEXP)

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'main'
  
  map.with_options :controller => 'articles' do |article|
    article.articles 'articles/by/:nick', :action => 'index',
                    :conditions => { :method => :get }
    article.new_article 'articles/by/:nick/new', :action => 'new',
                    :conditions => { :method => :get }
    article.create_article 'articles/by/:nick', :action => 'create',
                    :conditions => { :method => :post }
    article.update_article ':year/:month/:day/:permalink/by/:nick/update', :action => 'update',
                    :requirements => { :year => /\d{4}/, :month => /\d{2}/, :day => /\d{2}/,
                                       :permalink => REGEX[:permalink],
                                       :nick => /[-_a-z0-9]{3,}/i },
                    :conditions => { :method => :put }
    article.update_article 'drafts/:permalink/by/:nick/update', :action => 'update',
                    :conditions => { :method => :put }
    article.article ':year/:month/:day/:permalink/by/:nick/:action', :action => 'show',
                    :requirements => { :action => /(show|edit)?/, :year => /\d{4}/,
                                       :month => /\d{2}/, :day => /\d{2}/,
                                       :permalink => REGEX[:permalink],
                                       :nick => /[-_a-z0-9]{3,}/i },
                    :conditions => { :method => :get }
    article.article 'articles/:permalink/by/:nick', :action => 'show',
                    :requirements => { :permalink => REGEX[:permalink],
                                       :nick => /[-_a-z0-9]{3,}/i },
                    :conditions => { :method => :get }
    article.article 'articles/:permalink', :action => 'show',
                    :requirements => { :permalink => REGEX[:permalink] },
                    :conditions => { :method => :get }
    article.update_draft 'drafts/:permalink/by/:nick/update', :action => 'update_draft',
                    :requiremetns => { :permalink => REGEX[:permalink] },
                    :conditions => { :method => :put }
    article.draft 'drafts/:permalink/by/:nick/:action', :action => 'show_draft',
                    :requirements => { :permalink => REGEX[:permalink], :nick => /[-_a-z0-9]{3,}/i },
                    :conditions => { :method => :get }
  end

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
  
  map.posts 'user_posts *path', :controller => 'articles', :action => 'view'
    
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
