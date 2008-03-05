class ArticlesController < ApplicationController  
  #before_filter :verify_logged_in, :only => [:new, :create, :edit, :update]  
  #before_filter :setup, :except => [ :index, :list, :new, :create ]
  # FIXME: before_filter :only => [:edit, :update] { authenticate(@article) }
    
  #verify :method => :post, :only => [ ]
    
  def index
    subredirect
    limit, page = 10, params[:page].to_i + 1
    offset = params[:page].to_i * limit
    @articles = Article.find(:all, :limit => limit, :offset => offset, :order => 'id DESC')
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  def show
    @comments = @article.comments
  end
  
  def new
    @article = @viewer.articles.new
  end
  
  def create
    if @article = @viewer.articles.create(params[:article])
      respond_to do |format|
        format.html {
          flash[:notice] = 'Your article has been created'
          redirect_to article_url(@article)
        }
        format.js
      end
    else
      respond_to do |format|
        format.html {
          flash[:warning] = 'Your article could not be created.'
          redirect_to articles_url
        }
        format.js
      end
    end
  end
  
  def edit
    @comments = @article.comments
  end
  
  def update
    if @article.update_attributes(params)
      respond_to do |format|
        format.html {
          flash[:notice] = 'Your article has been updated.'
          redirect_to article_url(@article)
        }
        format.js
      end
    else
      respond_to do |format|
        format.html {
          flash[:notice] = 'Your article could not be updated.'
          redirect_to article_url(@article)
        }
        format.js
      end
    end
  end
  
  def destroy
    
  end
  
  private
  def setup(includes=nil)
    if params[:year] && params[:month] && params[:day]
      unless @article = Article.find_by_permalink(params[:year], params[:month], params[:day], params[:permalink])
        respond_to do |format|
          format.html {
            flash[:warning] = 'Article not found.'
            redirect_to articles_url
          }
          format.js {
            @warning = 'Article not found.'
            render :action => 'shared/warning'
          }
        end
      end
    end
  end

  def subredirect
    render :action => 'list'
    @skip_default_render = true
  end
end
