include ActiveRecord::Validations::RoutingHelper

class ActionController::Resources::Resource #:nodoc:
  def path; @path ||= @options[:special_path] || "#{path_prefix}/#{@options[:custom_path] || plural}"; end
end

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'main'  
  
  ################################################### USERS
  map.resources :users, :custom_path => 'u',
                :member => { :friends => :get, :befriend => :put, :unfriend => :put, :about => :get, :edit_password => :get, :update_password => :put } do |user|
    user.resources :blogs, :requirements => { :id => regex_for(:blog, :permalink) } do |blog|
      blog.resources :articles, :custom_path => ':year/:month/:day', :member => { :unpublish => :put},
                                :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                   :id => regex_for(:article, :permalink) } do |article|
        article.resources :clips, :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                     :article_id => regex_for(:article, :permalink) }
        article.resources :comments, :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                        :article_id => regex_for(:article, :permalink) }
        article.resources :pictures, :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                        :article_id => regex_for(:article, :permalink) } do |picture|
          picture.resources :clips, :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                       :article_id => regex_for(:article, :permalink) }
          picture.resources :comments, :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                          :article_id => regex_for(:article, :permalink) }
        end
      end
      blog.resources :clips, :requirements => { :blog_id => regex_for(:blog, :permalink) }
      blog.resources :comments, :requirements => { :blog_id => regex_for(:blog, :permalink) }
      blog.resources :drafts, :member => { :publish => :put }, :has_many => [ :pictures ],
                              :requirements => { :blog_id => regex_for(:blog, :permalink), :id => regex_for(:article, :permalink) }
      blog.resources :pictures, :requirements => { :blog_id => regex_for(:blog, :permalink)} do |picture|
        picture.resources :clips, :requirements => { :blog_id => regex_for(:blog, :permalink) }
        picture.resources :comments, :requirements => { :blog_id => regex_for(:blog, :permalink) }
      end
    end
    user.resources :clips
    user.resources :comments
    user.resources :events, :has_many => [ :clips, :comments ] do |event|
      event.resources :pictures, :has_many => [ :clips, :comments ]
    end
    user.resources :galleries, :has_many => [ :clips, :comments ] do |gallery|
      gallery.resources :pictures, :has_many => [ :clips, :comments ]
    end
    user.resources :pictures, :has_many => [ :clips, :comments ]
    user.resources :thoughtlets, :has_many => [ :clips, :comments ] do |thought|
      thought.resources :pictures, :has_many => [ :clips, :comments ]
    end
    user.resources :widgets, :has_many => [ :comments ]
  end
  
  #################################################### GROUPS
  map.resources :groups, :custom_path => 'g', :member => { :join => :put, :leave => :put, :kick => :put, :invite => :put } do |group|
    group.resources :blogs, :requirements => { :id => regex_for(:blog, :permalink) } do |blog|
      blog.resources :articles, :custom_path => ':year/:month/:day', :member => { :unpublish => :put },
                                :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                   :id => regex_for(:article, :permalink) } do |article|
        article.resources :clips, :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                     :article_id => regex_for(:article, :permalink) }
        article.resources :comments, :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                        :article_id => regex_for(:article, :permalink) }
        article.resources :pictures, :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                        :article_id => regex_for(:article, :permalink) } do |picture|
          picture.resources :clips, :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                       :article_id => regex_for(:article, :permalink) }
          picture.resources :comments, :requirements => { :blog_id => regex_for(:blog, :permalink), :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/,
                                                          :article_id => regex_for(:article, :permalink) }
        end
      end
      blog.resources :clips, :requirements => { :blog_id => regex_for(:blog, :permalink) }
      blog.resources :comments, :requirements => { :blog_id => regex_for(:blog, :permalink) }
      blog.resources :drafts, :member => { :publish => :put }, :has_many => [ :pictures ],
                              :requirements => { :blog_id => regex_for(:blog, :permalink), :id => regex_for(:article, :permalink) }
      blog.resources :pictures, :requirements => { :blog_id => regex_for(:blog, :permalink)} do |picture|
        picture.resources :clips, :requirements => { :blog_id => regex_for(:blog, :permalink) }
        picture.resources :comments, :requirements => { :blog_id => regex_for(:blog, :permalink) }
      end
    end
    group.resources :clips
    group.resources :comments
    group.resources :pictures, :has_many => [ :clips, :comments ]
  end
  
  map.resources :messages, :requirements => { :id => regex_for(:message, :id) }
  map.resources :permissions, :requirements => { :id => regex_for(:permission_rule, :id) }
  
  map.search 'search/:query', :controller => 'search', :action => 'index', :query => nil
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
  
  
  #### PREMIUM URLS
  #map.resources :blogs, :special_path => ''
end
