include ActiveRecord::Validations::RoutingHelper

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'main'
  
  # User Blog Articles
  map.with_options :controller => 'articles', :path_prefix => 'u/:user_id/:blog_id',
                                              :requirements => { :user_id => regex_for(:user, :nick), :blog_id => regex_for(:blog, :permalink) } do |ar|
    ar.user_articles              'articles',             :action => 'index',  :conditions => { :method => :get }
    ar.formatted_user_articles    'articles.:format',     :action => 'index',  :conditions => { :method => :get }
    ar.connect                    'articles',             :action => 'create', :conditions => { :method => :post }
    ar.connect                    'articles.:format',     :action => 'create', :conditions => { :method => :post }
    ar.new_user_article           'articles/new',         :action => 'new',    :conditions => { :method => :get }
    ar.formatted_new_user_article 'article/new.:format',  :action => 'new',    :conditions => { :method => :get }
    
    ar.with_options :path_prefix => 'u/:user_id/:blog_id/:year/:month/:day/:id',
                    :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :id => regex_for(:article, :permalink) } do |arpm|
      arpm.edit_user_article                'edit',              :action => 'edit',      :conditions => { :method => :get }
      arpm.formatted_edit_user_article      'edit.:format',      :action => 'edit',      :conditions => { :method => :get }
      arpm.unpublish_user_article           'unpublish',         :action => 'unpublish', :conditions => { :method => :put }
      arpm.formatted_unpublish_user_article 'unpublish.:format', :action => 'unpublish', :conditions => { :method => :put }
      arpm.user_article                     '',                  :action => 'show',      :conditions => { :method => :get }                                                                                                      
      arpm.formatted_user_article           '.:format',          :action => 'show',      :conditions => { :method => :get }
      arpm.connect                          '',                  :action => 'update',    :conditions => { :method => :put }
      arpm.connect                          '.:format',          :action => 'update',    :conditions => { :method => :put }
      arpm.connect                          '',                  :action => 'destroy',   :conditions => { :method => :delete }
      arpm.connect                          '.:format',          :action => 'destroy',   :conditions => { :method => :delete }
    end
    ar.with_options :requirements => { :id => regex_for(:article, :permalink) } do |par|
      par.user_particles               'articles/:id',               :action => 'show',    :conditions =>   { :method => :get }
      par.formatted_user_particles     'articles/:id.:format',       :action => 'show',    :conditions =>   { :method => :get }
      par.edit_user_draft              'draft/:id/edit',             :action => 'edit',    :conditions =>   { :method => :get }
      par.formatted_edit_user_draft    'draft/:id/edit.:format',     :action => 'edit',    :conditions =>   { :method => :get }
      par.publish_user_draft           'draft/:id/publish',          :action => 'publish', :conditions =>   { :method => :put }
      par.formatted_publish_user_draft 'draft/:id/publish.:format',  :action => 'publish', :conditions =>   { :method => :put }
      par.user_draft                   'draft/:id',                  :action => 'show',    :conditions =>   { :method => :get }
      par.formatted_user_draft         'draft/:id.:format',          :action => 'show',    :conditions =>   { :method => :get }
      par.connect                      'draft/:id',                  :action => 'update',  :conditions =>   { :method => :put }
      par.connect                      'draft/:id.:format',          :action => 'update',  :conditions =>   { :method => :put }
      par.connect                      'draft/:id',                  :action => 'destroy', :conditions =>   { :method => :delete }
      par.connect                      'draft/:id.:format',          :action => 'destroy', :conditions =>   { :method => :delete }
    end
  end
  
  ### User Draft Pictures ##
  map.with_options :controller => 'pictures', :path_prefix => 'u/:user_id/:blog_id/draft/:article_id',
                   :requirements => { :article_id => regex_for(:article, :permalink), :user_id => regex_for(:user, :nick),
                                      :blog_id    => regex_for(:blog, :permalink) } do |draft|
    draft.user_draft_pictures              'pictures',             :action => 'index',  :conditions => { :method => :get }
    draft.formatted_user_draft_pictures    'pictures.:format',     :action => 'index',  :conditions => { :method => :get }
    draft.connect                          'pictures',             :action => 'create', :conditions => { :method => :post }
    draft.connect                          'pictures.:format',     :action => 'create', :conditions => { :method => :post }
    draft.new_user_draft_picture           'pictures/new',         :action => 'new',    :conditions => { :method => :get }
    draft.formatted_new_user_draft_picture 'pictures/new.:format', :action => 'new',    :conditions => { :method => :get }
    draft.with_options :requirements => { :id => regex_for(:picture, :id) } do |drp|
      drp.edit_user_draft_picture           'pictures/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
      drp.formatted_edit_user_draft_picture 'pictures/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
      drp.user_draft_picture                'pictures/:id',              :action => 'show',    :conditions => { :method => :get }
      drp.formatted_user_draft_picture      'pictures/:id.:format',      :action => 'show',    :conditions => { :method => :get }
      drp.connect                           'pictures/:id',              :action => 'update',  :conditions => { :method => :put }
      drp.connect                           'pictures/:id.:format',      :action => 'update',  :conditions => { :method => :put }
      drp.connect                           'pictures/:id',              :action => 'destroy', :conditions => { :method => :delete }
      drp.connect                           'pictures/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
    end
  end
  
  
  ### A R T I C L E   S U B S E T S ##
  # Notice that in the article_clips routes, there aren't paths to Draft clips. That's because
  # Drafts aren't public. Intentionally done. This means I don't need to check #widgetable? on
  # a draft. Routing handles that.
  map.with_options :path_prefix => 'u/:user_id/:blog_id/:year/:month/:day/:article_id',
                   :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :article_id => regex_for(:article, :permalink),
                                      :user_id => regex_for(:user, :nick), :blog_id => regex_for(:blog, :permalink) } do |ars|
    # User -> Article -> Clips
    ars.with_options :controller => 'clips' do |cl|
      cl.user_article_clips              'clips',             :action => 'index',  :conditions => { :method => :get }
      cl.formatted_user_article_clips    'clips.:format',     :action => 'index',  :conditions => { :method => :get }
      cl.connect                         'clips',             :action => 'create', :conditions => { :method => :post }
      cl.connect                         'clips.:format',     :action => 'create', :conditions => { :method => :post }
      cl.new_user_article_clip           'clips/new',         :action => 'new',    :conditions => { :method => :get }
      cl.formatted_new_user_article_clip 'clips/new.:format', :action => 'new',    :conditions => { :method => :get }
      cl.with_options :requirements => { :id => regex_for(:clip, :id) } do |cli|
        cl.edit_user_article_clip           'clips/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
        cl.formatted_edit_user_article_clip 'clips/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
        cl.user_article_clip                'clips/:id',              :action => 'show',    :conditions => { :method => :get }
        cl.formatted_user_article_clip      'clips/:id.:format',      :action => 'show',    :conditions => { :method => :get }
        cl.connect                          'clips/:id',              :action => 'update',  :conditions => { :method => :put }
        cl.connect                          'clips/:id.:format',      :action => 'update',  :conditions => { :method => :put }
        cl.connect                          'clips/:id',              :action => 'destroy', :conditions => { :method => :delete }
        cl.connect                          'clips/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
      end
    end
    # User -> Article -> Comments
    ars.with_options :controller => 'comments' do |cm|
      cm.user_article_comments              'comments',             :action => 'index',  :conditions => { :method => :get }
      cm.formatted_user_article_comments    'comments.:format',     :action => 'index',  :conditions => { :method => :get }
      cm.connect                            'comments',             :action => 'create', :conditions => { :method => :post }
      cm.connect                            'comments.:format',     :action => 'create', :conditions => { :method => :post }
      cm.new_user_article_comment           'comments/new',         :action => 'new',    :conditions => { :method => :get }
      cm.formatted_new_user_article_comment 'comments/new.:format', :action => 'new',    :conditions => { :method => :get }
      cm.with_options :requirements => { :id => regex_for(:comment, :id) } do |cmi|
        cmi.edit_user_article_comment           'comments/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
        cmi.formatted_edit_user_article_comment 'comments/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
        cmi.user_article_comment                'comments/:id',              :action => 'show',    :conditions => { :method => :get }
        cmi.formatted_user_article_comment      'comments/:id.:format',      :action => 'show',    :conditions => { :method => :get }
        cmi.connect                             'comments/:id',              :action => 'update',  :conditions => { :method => :put }
        cmi.connect                             'comments/:id.:format',      :action => 'update',  :conditions => { :method => :put }
        cmi.connect                             'comments/:id',              :action => 'destroy', :conditions => { :method => :delete }
        cmi.connect                             'comments/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
      end
    end
    # User -> Article -> Pictures
    ars.with_options :controller => 'pictures' do |pic|
      pic.user_article_pictures              'pictures',             :action => 'index',  :conditions => { :method => :get }
      pic.formatted_user_article_pictures    'pictures.:format',     :action => 'index',  :conditions => { :method => :get }
      pic.connect                            'pictures',             :action => 'create', :conditions => { :method => :post }
      pic.connect                            'pictures.:format',     :action => 'create', :conditions => { :method => :post }
      pic.new_user_article_picture           'pictures/new',         :action => 'new',    :conditions => { :method => :get }
      pic.formatted_new_user_article_picture 'pictures/new.:format', :action => 'new',    :conditions => { :method => :get }
      pic.with_options :requirements => { :id => regex_for(:picture, :id) } do |pici|
        pici.edit_user_article_picture           'pictures/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
        pici.formatted_edit_user_article_picture 'pictures/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
        pici.user_article_picture                'pictures/:id',              :action => 'show',    :conditions => { :method => :get }
        pici.formatted_user_article_picture      'pictures/:id.:format',      :action => 'show',    :conditions => { :method => :get }
        pici.connect                             'pictures/:id',              :action => 'update',  :conditions => { :method => :put }
        pici.connect                             'pictures/:id.:format',      :action => 'update',  :conditions => { :method => :put }
        pici.connect                             'pictures/:id',              :action => 'destroy', :conditions => { :method => :delete }
        pici.connect                             'pictures/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
      end
      # User -> Article -> Picture -> Clips
      pic.with_options :controller => 'clips', :path_prefix => 'u/:user_id/:blog_id/:year/:month/:day/:article_id/pictures/:picture_id',
                                               :requirements => { :picture_id => regex_for(:picture, :id) } do |pcl|
        pcl.user_article_picture_clips              'clips',             :action => 'index',  :conditions => { :method => :get }
        pcl.formatted_user_article_picture_clips     'clips.:format',     :action => 'index',  :conditions => { :method => :get }
        pcl.connect                                 'clips',             :action => 'create', :conditions => { :method => :post }
        pcl.connect                                 'clips.:format',     :action => 'create', :conditions => { :method => :post }
        pcl.new_user_article_picture_clip           'clips/new',         :action => 'new',    :conditions => { :method => :get }
        pcl.formatted_new_user_article_picture_clip 'clips/new.:format', :action => 'new',    :conditions => { :method => :get }
        pcl.with_options :requirements => { :id => regex_for(:clip, :id) } do |pcli|
          pcli.edit_user_article_picture_clip           'clips/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
          pcli.formatted_edit_user_article_picture_clip 'clips/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
          pcli.user_article_picture_clip                'clips/:id',              :action => 'show',    :conditions => { :method => :get }
          pcli.formatted_user_article_picture_clip      'clips/:id.:format',      :action => 'show',    :conditions => { :method => :get }
          pcli.connect                                  'clips/:id',              :action => 'update',  :conditions => { :method => :put }
          pcli.connect                                  'clips/:id.:format',      :action => 'update',  :conditions => { :method => :put }
          pcli.connect                                  'clips/:id',              :action => 'destroy', :conditions => { :method => :delete }
          pcli.connect                                  'clips/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
        end
      end
      # User -> Article -> Picture -> Comments
      pic.with_options :controller => 'comments', :path_prefix => 'u/:user_id/:blog_id/:year/:month/:day/:article_id/pictures/:picture_id',
                                                  :requirements => { :picture_id => regex_for(:picture, :id) } do |pcm|
        pcm.user_article_picture_comments              'comments',             :action => 'index',  :conditions => { :method => :get }
        pcm.formatted_user_article_picture_comments    'comments.:format',     :action => 'index',  :conditions => { :method => :get }
        pcm.connect                                    'comments',             :action => 'create', :conditions => { :method => :post }
        pcm.connect                                    'comments.:format',     :action => 'create', :conditions => { :method => :post }
        pcm.new_user_article_picture_comment           'comments/new',         :action => 'new',    :conditions => { :method => :get }
        pcm.formatted_new_user_article_picture_comment 'comments/new.:format', :action => 'new',    :conditions => { :method => :get }
        pcm.with_options :requirements => { :id => regex_for(:comment, :id) } do |pcmi|
          pcmi.edit_user_article_picture_comment           'comments/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
          pcmi.formatted_edit_user_article_picture_comment 'comments/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
          pcmi.user_article_picture_comment                'comments/:id',              :action => 'show',    :conditions => { :method => :get }
          pcmi.formatted_user_article_picture_comment      'comments/:id.:format',      :action => 'show',    :conditions => { :method => :get }
          pcmi.connect                                     'comments/:id',              :action => 'update',  :conditions => { :method => :put }
          pcmi.connect                                     'comments/:id.:format',      :action => 'update',  :conditions => { :method => :put }
          pcmi.connect                                     'comments/:id',              :action => 'destroy', :conditions => { :method => :delete }
          pcmi.connect                                     'comments/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
        end
      end
    end
  end
  
  
  ########## GROUP ARTICLES################
  
  
  # Group -> Articles
  map.with_options :controller => 'articles', :path_prefix => 'g/:group_id/:blog_id',
                                              :requirements => { :group_id => regex_for(:group, :name), :blog_id => regex_for(:blog, :permalink) } do |ar|
    ar.group_articles               'articles',             :action => 'index',  :conditions => { :method => :get }
    ar.formatted_group_articles     'articles.:format',     :action => 'index',  :conditions => { :method => :get }
    ar.connect                      'articles',             :action => 'create', :conditions => { :method => :post }
    ar.connect                      'articles.:format',     :action => 'create', :conditions => { :method => :post }
    ar.new_group_article            'articles/new',         :action => 'new',    :conditions => { :method => :get }
    ar.formatted_new_groupo_article 'article/new.:format',  :action => 'new',    :conditions => { :method => :get }
    
    ar.with_options :path_prefix => 'g/:group_id/:blog_id/:year/:month/:day/:id',
                    :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :id => regex_for(:article, :permalink) } do |arpm|
      arpm.edit_group_article                'edit',              :action => 'edit',      :conditions => { :method => :get }
      arpm.formatted_edit_group_article      'edit.:format',      :action => 'edit',      :conditions => { :method => :get }
      arpm.unpublish_group_article           'unpublish',         :action => 'unpublish', :conditions => { :method => :put }
      arpm.formatted_unpublish_group_article 'unpublish.:format', :action => 'unpublish', :conditions => { :method => :put }
      arpm.group_article                     '',                  :action => 'show',      :conditions => { :method => :get }                                                                                                      
      arpm.formatted_group_article           '.:format',          :action => 'show',      :conditions => { :method => :get }
      arpm.connect                           '',                  :action => 'update',    :conditions => { :method => :put }
      arpm.connect                           '.:format',          :action => 'update',    :conditions => { :method => :put }
      arpm.connect                           '',                  :action => 'destroy',   :conditions => { :method => :delete }
      arpm.connect                           '.:format',          :action => 'destroy',   :conditions => { :method => :delete }
    end
    ar.with_options :requirements => { :id => regex_for(:article, :permalink) } do |par|
      par.group_particles                'articles/:id',               :action => 'show',    :conditions =>   { :method => :get }
      par.formatted_group_particles      'articles/:id.:format',       :action => 'show',    :conditions =>   { :method => :get }
      par.edit_group_draft               'draft/:id/edit',             :action => 'edit',    :conditions =>   { :method => :get }
      par.formatted_edit_grouop_draft    'draft/:id/edit.:format',     :action => 'edit',    :conditions =>   { :method => :get }
      par.publish_group_draft            'draft/:id/publish',          :action => 'publish', :conditions =>   { :method => :put }
      par.formatted_publish_group_draft  'draft/:id/publish.:format',  :action => 'publish', :conditions =>   { :method => :put }
      par.group_draft                    'draft/:id',                  :action => 'show',    :conditions =>   { :method => :get }
      par.formatted_group_draft          'draft/:id.:format',          :action => 'show',    :conditions =>   { :method => :get }
      par.connect                        'draft/:id',                  :action => 'update',  :conditions =>   { :method => :put }
      par.connect                        'draft/:id.:format',          :action => 'update',  :conditions =>   { :method => :put }
      par.connect                        'draft/:id',                  :action => 'destroy', :conditions =>   { :method => :delete }
      par.connect                        'draft/:id.:format',          :action => 'destroy', :conditions =>   { :method => :delete }
    end
  end
  
  # Group -> Draft -> Pictures
  map.with_options :controller => 'pictures', :path_prefix => 'g/:group_id/:blog_id/draft/:article_id',
                   :requirements => { :article_id => regex_for(:article, :permalink), :group_id => regex_for(:group, :name),
                                      :blog_id    => regex_for(:blog, :permalink) } do |draft|
    draft.group_draft_pictures              'pictures',             :action => 'index',  :conditions => { :method => :get }
    draft.formatted_group_draft_pictures    'pictures.:format',     :action => 'index',  :conditions => { :method => :get }
    draft.connect                           'pictures',             :action => 'create', :conditions => { :method => :post }
    draft.connect                           'pictures.:format',     :action => 'create', :conditions => { :method => :post }
    draft.new_group_draft_picture           'pictures/new',         :action => 'new',    :conditions => { :method => :get }
    draft.formatted_new_group_draft_picture 'pictures/new.:format', :action => 'new',    :conditions => { :method => :get }
    draft.with_options :requirements => { :id => regex_for(:picture, :id) } do |drp|
      drp.edit_group_draft_picture           'pictures/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
      drp.formatted_edit_group_draft_picture 'pictures/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
      drp.group_draft_picture                'pictures/:id',              :action => 'show',    :conditions => { :method => :get }
      drp.formatted_group_draft_picture      'pictures/:id.:format',      :action => 'show',    :conditions => { :method => :get }
      drp.connect                            'pictures/:id',              :action => 'update',  :conditions => { :method => :put }
      drp.connect                            'pictures/:id.:format',      :action => 'update',  :conditions => { :method => :put }
      drp.connect                            'pictures/:id',              :action => 'destroy', :conditions => { :method => :delete }
      drp.connect                            'pictures/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
    end
  end

  map.with_options :path_prefix => 'g/:group_id/:blog_id/:year/:month/:day/:article_id',
                   :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :article_id => regex_for(:article, :permalink),
                                      :group_id => regex_for(:group, :name), :blog_id => regex_for(:blog, :permalink) } do |ars|
    # Group -> Article -> Clips
    ars.with_options :controller => 'clips' do |cl|
      cl.group_article_clips              'clips',             :action => 'index',  :conditions => { :method => :get }
      cl.formatted_group_article_clips    'clips.:format',     :action => 'index',  :conditions => { :method => :get }
      cl.connect                          'clips',             :action => 'create', :conditions => { :method => :post }
      cl.connect                          'clips.:format',     :action => 'create', :conditions => { :method => :post }
      cl.new_group_article_clip           'clips/new',         :action => 'new',    :conditions => { :method => :get }
      cl.formatted_new_group_article_clip 'clips/new.:format', :action => 'new',    :conditions => { :method => :get }
      cl.with_options :requirements => { :id => regex_for(:clip, :id) } do |cli|
        cl.edit_group_article_clip           'clips/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
        cl.formatted_edit_group_article_clip 'clips/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
        cl.group_article_clip                'clips/:id',              :action => 'show',    :conditions => { :method => :get }
        cl.formatted_group_article_clip      'clips/:id.:format',      :action => 'show',    :conditions => { :method => :get }
        cl.connect                           'clips/:id',              :action => 'update',  :conditions => { :method => :put }
        cl.connect                           'clips/:id.:format',      :action => 'update',  :conditions => { :method => :put }
        cl.connect                           'clips/:id',              :action => 'destroy', :conditions => { :method => :delete }
        cl.connect                           'clips/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
      end
    end
    # Group -> Article -> Comments
    ars.with_options :controller => 'comments' do |cm|
      cm.group_article_comments              'comments',             :action => 'index',  :conditions => { :method => :get }
      cm.formatted_group_article_comments    'comments.:format',     :action => 'index',  :conditions => { :method => :get }
      cm.connect                             'comments',             :action => 'create', :conditions => { :method => :post }
      cm.connect                             'comments.:format',     :action => 'create', :conditions => { :method => :post }
      cm.new_group_article_comment           'comments/new',         :action => 'new',    :conditions => { :method => :get }
      cm.formatted_new_group_article_comment 'comments/new.:format', :action => 'new',    :conditions => { :method => :get }
      cm.with_options :requirements => { :id => regex_for(:comment, :id) } do |cmi|
        cmi.edit_group_article_comment           'comments/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
        cmi.formatted_edit_group_article_comment 'comments/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
        cmi.group_article_comment                'comments/:id',              :action => 'show',    :conditions => { :method => :get }
        cmi.formatted_group_article_comment      'comments/:id.:format',      :action => 'show',    :conditions => { :method => :get }
        cmi.connect                              'comments/:id',              :action => 'update',  :conditions => { :method => :put }
        cmi.connect                              'comments/:id.:format',      :action => 'update',  :conditions => { :method => :put }
        cmi.connect                              'comments/:id',              :action => 'destroy', :conditions => { :method => :delete }
        cmi.connect                              'comments/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
      end
    end
    # Group -> Article -> Pictures
    ars.with_options :controller => 'pictures' do |pic|
      pic.group_article_pictures              'pictures',             :action => 'index',  :conditions => { :method => :get }
      pic.formatted_group_article_pictures    'pictures.:format',     :action => 'index',  :conditions => { :method => :get }
      pic.connect                             'pictures',             :action => 'create', :conditions => { :method => :post }
      pic.connect                             'pictures.:format',     :action => 'create', :conditions => { :method => :post }
      pic.new_group_article_picture           'pictures/new',         :action => 'new',    :conditions => { :method => :get }
      pic.formatted_new_group_article_picture 'pictures/new.:format', :action => 'new',    :conditions => { :method => :get }
      pic.with_options :requirements => { :id => regex_for(:picture, :id) } do |pici|
        pici.edit_group_article_picture           'pictures/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
        pici.formatted_edit_group_article_picture 'pictures/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
        pici.group_article_picture                'pictures/:id',              :action => 'show',    :conditions => { :method => :get }
        pici.formatted_group_article_picture      'pictures/:id.:format',      :action => 'show',    :conditions => { :method => :get }
        pici.connect                              'pictures/:id',              :action => 'update',  :conditions => { :method => :put }
        pici.connect                              'pictures/:id.:format',      :action => 'update',  :conditions => { :method => :put }
        pici.connect                              'pictures/:id',              :action => 'destroy', :conditions => { :method => :delete }
        pici.connect                              'pictures/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
      end
      # Group -> Article -> Picture -> Clips
      pic.with_options :controller => 'clips', :path_prefix => 'g/:group_id/:blog_id/:year/:month/:day/:article_id/pictures/:picture_id',
                                               :requirements => { :picture_id => regex_for(:picture, :id) } do |pcl|
        pcl.group_article_picture_clips              'clips',             :action => 'index',  :conditions => { :method => :get }
        pcl.formatted_group_article_picture_clips    'clips.:format',     :action => 'index',  :conditions => { :method => :get }
        pcl.connect                                  'clips',             :action => 'create', :conditions => { :method => :post }
        pcl.connect                                  'clips.:format',     :action => 'create', :conditions => { :method => :post }
        pcl.new_group_article_picture_clip           'clips/new',         :action => 'new',    :conditions => { :method => :get }
        pcl.formatted_new_group_article_picture_clip 'clips/new.:format', :action => 'new',    :conditions => { :method => :get }
        pcl.with_options :requirements => { :id => regex_for(:clip, :id) } do |pcli|
          pcli.edit_group_article_picture_clip           'clips/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
          pcli.formatted_edit_group_article_picture_clip 'clips/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
          pcli.group_article_picture_clip                'clips/:id',              :action => 'show',    :conditions => { :method => :get }
          pcli.formatted_group_article_picture_clip      'clips/:id.:format',      :action => 'show',    :conditions => { :method => :get }
          pcli.connect                                   'clips/:id',              :action => 'update',  :conditions => { :method => :put }
          pcli.connect                                   'clips/:id.:format',      :action => 'update',  :conditions => { :method => :put }
          pcli.connect                                   'clips/:id',              :action => 'destroy', :conditions => { :method => :delete }
          pcli.connect                                   'clips/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
        end
      end
      # Group - Article -> Picture -> Comments
      pic.with_options :controller => 'comments', :path_prefix => 'g/:group_id/:blog_id/:year/:month/:day/:article_id/pictures/:picture_id',
                                                  :requirements => { :picture_id => regex_for(:picture, :id) } do |pcm|
        pcm.group_article_picture_comments              'comments',             :action => 'index',  :conditions => { :method => :get }
        pcm.formatted_group_article_picture_comments    'comments.:format',     :action => 'index',  :conditions => { :method => :get }
        pcm.connect                                     'comments',             :action => 'create', :conditions => { :method => :post }
        pcm.connect                                     'comments.:format',     :action => 'create', :conditions => { :method => :post }
        pcm.new_group_article_picture_comment           'comments/new',         :action => 'new',    :conditions => { :method => :get }
        pcm.formatted_new_group_article_picture_comment 'comments/new.:format', :action => 'new',    :conditions => { :method => :get }
        pcm.with_options :requirements => { :id => regex_for(:comment, :id) } do |pcmi|
          pcmi.edit_group_article_picture_comment           'comments/:id/edit',         :action => 'edit',    :conditions => { :method => :get }
          pcmi.formatted_edit_group_article_picture_comment 'comments/:id/edit.:format', :action => 'edit',    :conditions => { :method => :get }
          pcmi.group_article_picture_comment                'comments/:id',              :action => 'show',    :conditions => { :method => :get }
          pcmi.formatted_group_article_picture_comment      'comments/:id.:format',      :action => 'show',    :conditions => { :method => :get }
          pcmi.connect                                      'comments/:id',              :action => 'update',  :conditions => { :method => :put }
          pcmi.connect                                      'comments/:id.:format',      :action => 'update',  :conditions => { :method => :put }
          pcmi.connect                                      'comments/:id',              :action => 'destroy', :conditions => { :method => :delete }
          pcmi.connect                                      'comments/:id.:format',      :action => 'destroy', :conditions => { :method => :delete }
        end
      end
    end
  end
  
  
  
  
  ########### NORMAL STUFF #################
  map.resources :groups, :requirements => { :id => regex_for(:group, :id) }, :member => { :join => :put, :leave => :put, :kick => :put, :invite => :put } do |grp|
    grp.resources :blogs, :requirements => { :group_id => regex_for(:group, :id),
                                             :id => regex_for(:blog, :permalink) } do |gbg|
      gbg.resources :clips, :requirements => { :group_id => regex_for(:group, :id),
                                               :blog_id => regex_for(:blog, :permalink),
                                               :id => regex_for(:clip, :id) }
      gbg.resources :comments, :requirements => { :group_id => regex_for(:group, :id),
                                                  :blog_id => regex_for(:blog, :permalink),
                                                  :id => regex_for(:comment, :id) }
      gbg.resources :pictures, :requirements => { :group_id => regex_for(:group, :id),
                                                  :blog_id => regex_for(:blog, :permalink),
                                                  :id => regex_for(:picture, :id) } do |gbpic|
        gbpic.resources :clips, :requirements => { :group_id => regex_for(:group, :id),
                                                   :blog_id => regex_for(:blog, :permalink),
                                                   :picture_id => regex_for(:picture, :id),
                                                   :id => regex_for(:clip, :id) }
        gbpic.resources :comments, :requirements => { :group_id => regex_for(:group, :id),
                                                      :blog_id => regex_for(:blog, :permalink),
                                                      :picture_id => regex_for(:picture, :id),
                                                      :id => regex_for(:comment, :id) }
      end
    end
    grp.resources :clips, :requirements => { :group_id => regex_for(:group, :id),
                                             :id => regex_for(:clip, :id) }
    grp.resources :comments, :requirements => { :group_id => regex_for(:group, :id),
                                                :id => regex_for(:comment, :id) }
    grp.resources :pictures, :requirements => { :group_id => regex_for(:group, :id),
                                                :id => regex_for(:picture, :id) } do |gpic|
      gpic.resources :clips, :requirements => { :group_id => regex_for(:group, :id),
                                                :picture_id => regex_for(:picture, :id),
                                                :id => regex_for(:clip, :id) }
      gpic.resources :comments, :requirements => { :group_id => regex_for(:group, :id),
                                                   :picture_id => regex_for(:picture, :id),
                                                   :id => regex_for(:comment, :id) }
    end
  end
  map.resources :messages, :requirements => { :id => regex_for(:message, :id) }
  # TODO: Allow a param to specify who message is to.
  map.resources :permissions, :requirements => { :id => regex_for(:permission_rule, :id) }
  map.resources :users, :member => { :friends => :get, :befriend => :put, :unfriend => :put,
                        :about => :get, :edit_password => :get, :update_password => :put },
                        :requirements => { :id => regex_for(:user, :nick) } do |user|
    user.resources :blogs, :requirements => { :user_id => regex_for(:user, :nick),
                                              :id => regex_for(:blog, :permalink) } do |bg|
      bg.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                              :blog_id => regex_for(:blog, :permalink),
                                              :id => regex_for(:clip, :id) }
      bg.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :blog_id => regex_for(:blog, :permalink),
                                                 :id => regex_for(:comment, :id) }
      bg.resources :pictures, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :blog_id => regex_for(:blog, :permalink),
                                                 :id => regex_for(:picture, :id) } do |bgp|
        bgp.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :blog_id => regex_for(:blog, :permalink),
                                                 :picture_id => regex_for(:picture, :id),
                                                 :id => regex_for(:clip, :id) }
        bgp.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                    :blog_id => regex_for(:blog, :permalink),
                                                    :picture_id => regex_for(:picture, :id),
                                                    :id => regex_for(:comment, :id) }
      end
    end
    user.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                              :id => regex_for(:clip, :id) }
    user.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :id => regex_for(:comment, :id) }
    user.resources :thoughtlets, :requirements => { :user_id => regex_for(:user, :nick), :id => regex_for(:thoughtlet, :id) } do |thoughtlet|
      thoughtlet.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                                      :thoughtlet_id => regex_for(:thoughtlet, :id),
                                                      :id => regex_for(:clip, :id) }
      thoughtlet.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                         :thoughtlet_id => regex_for(:thoughtlet, :id),
                                                         :id => regex_for(:comment, :id) }
      thoughtlet.resources :pictures, :requirements => { :user_id => regex_for(:user, :nick),
                                                         :thoughtlet_id => regex_for(:thoughtlet, :id),
                                                         :id => regex_for(:picture, :id) } do |ep|
        ep.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                                :thoughtlet_id => regex_for(:thoughtlet, :id),
                                                :picture_id => regex_for(:picture, :id),
                                                :id => regex_for(:clip, :id) }
        ep.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                   :thoughtlet_id => regex_for(:thoughtlet, :id),
                                                   :picture_id => regex_for(:picture, :id),
                                                   :id => regex_for(:comment, :id) }
      end
    end
    user.resources :events, :member => { :begin_event => :put, :end_event => :put }, :requirements => { :user_id => regex_for(:user, :nick), :id => regex_for(:event, :id) } do |event|
      event.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :event_id => regex_for(:event, :id),
                                                 :id => regex_for(:clip, :id) }
      event.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                    :event_id => regex_for(:event, :id),
                                                    :id => regex_for(:comment, :id) }
      event.resources :pictures, :requirements => { :user_id => regex_for(:user, :nick),
                                                    :event_id => regex_for(:event, :id),
                                                    :id => regex_for(:picture, :id) } do |uep|
        uep.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :event_id => regex_for(:event, :id),
                                                 :picture_id => regex_for(:picture, :id),
                                                 :id => regex_for(:clip, :id) }
        uep.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                    :event_id => regex_for(:event, :id),
                                                    :picture_id => regex_for(:picture, :id),
                                                    :id => regex_for(:comment, :id) }
      end
    end
    user.resources :galleries, :requirements => { :id => regex_for(:gallery, :id) } do |gal|
      gal.resources :clips, :requirements => { :gallery_id => regex_for(:gallery, :id),
                                               :id => regex_for(:clip, :id) }
      gal.resources :comments, :requirements => { :gallery_id => regex_for(:gallery, :id),
                                                  :id => regex_for(:comment, :id) }
      gal.resources :pictures, :requirements => { :gallery_id => regex_for(:gallery, :id),
                                                  :id => regex_for(:picture, :id) } do |gp|
        gp.resources :clips, :requirements => { :gallery_id => regex_for(:gallery, :id),
                                                :picture_id => regex_for(:picture, :id),
                                                :id => regex_for(:clip, :id) }
        gp.resources :comments, :requirements => { :gallery_id => regex_for(:gallery, :id),
                                                   :picture_id => regex_for(:picture, :id),
                                                   :id => regex_for(:comment, :id) }
      end
    end
    user.resources :pictures, :requirements => { :user_id => regex_for(:user, :nick), :id => regex_for(:picture, :id) } do |up|
      up.resources :clips, :requirements => { :user_id => regex_for(:user, :nick),
                                              :picture_id => regex_for(:picture, :id),
                                              :id => regex_for(:clip, :id) }
      up.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :picture_id => regex_for(:picture, :id),
                                                 :id => regex_for(:comment, :id) }
    end
    user.resources :widgets, :member => { :place => :put, :unplace => :put }, :requirements => { :user_id => regex_for(:user, :nick), :id => regex_for(:widget, :id) } do |uw|
      uw.resources :comments, :requirements => { :user_id => regex_for(:user, :nick),
                                                 :widget_id => regex_for(:widget, :id),
                                                 :id => regex_for(:comment, :id) }
    end
  end
  
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
end
