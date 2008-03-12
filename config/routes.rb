#require File.join(RAILS_ROOT,  'lib/active_record/validations/constants') unless Object.const_defined?(:REGEXP)
include ActiveRecord::Validations::RoutingHelper

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'main'
  
  map.with_options :controller => 'articles' do |article|
    article.articles 'articles/by/:nick', :action => 'index',
                    :conditions => { :method => :get },
                    :requirements => { :nick => regex_for(:user, :nick) }
    article.connect 'articles', :action => 'create',
                    :conditions => { :method => :post }
    article.new_article 'articles/by/:nick/new', :action => 'new',
                    :conditions => { :method => :get },
                    :requirements => { :nick => regex_for(:user, :nick) }
    article.connect ':year/:month/:day/:permalink/by/:nick',
                    :action => 'update',
                    :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                       :permalink => regex_for(:article, :permalink),
                                       :nick => regex_for(:user, :nick) },
                    :conditions => { :method => :put }
    article.connect 'drafts/:permalink/by/:nick', :action => 'update',
                    :conditions => { :method => :put }
    article.article ':year/:month/:day/:permalink/by/:nick', :action => 'show',
                    :requirements => { :year => /\d{4}/,
                                       :month => /\d{1,2}/, :day => /\d{1,2}/,
                                       :permalink => regex_for(:article, :permalink),
                                       :nick => regex_for(:user, :nick) },
                    :conditions => { :method => :get }
    article.edit_article ':year/:month/:day/:permalink/by/:nick/edit', :action => 'edit',
                    :requirements => { :year => /\d{4}/, :month => /\d{1,2}/,
                                       :day => /\d{1,2}/,
                                       :permalink => regex_for(:article, :permalink),
                                       :nick => regex_for(:user, :nick) }
    article.particle 'articles/:permalink/by/:nick', :action => 'show',
                    :requirements => { :permalink => regex_for(:article, :permalink),
                                       :nick => regex_for(:user, :nick) },
                    :conditions => { :method => :get }
    article.particle 'articles/:permalink', :action => 'show',
                    :requirements => { :permalink => regex_for(:article, :permalink) },
                    :conditions => { :method => :get }
    article.update_draft 'drafts/:permalink/by/:nick', :action => 'update_draft',
                    :requirements => { :permalink => regex_for(:article, :permalink) },
                    :conditions => { :method => :put }
    article.draft 'drafts/:permalink/by/:nick/:action', :action => 'show_draft',
                    :requirements => { :permalink => regex_for(:article, :permalink),
                                       :nick => regex_for(:user, :nick) },
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
                :member => { :friends => :get, :befriend => :put, :unfriend => :put,
                             :about => :get, :edit_password => :get,
                             :update_password => :put },
                :requirements => { :id => regex_for(:user, :nick) } do |user|
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
