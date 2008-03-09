class ArticlesController < ApplicationController  
  
  def index
    super
  end
  
  def show
    super
  end
  
  def new
    super
  end
  
  def create
    super
  end
  
  def edit
    super
  end
  
  def update
    super
  end
  
  def destroy
    super
  end
  
  private
  
  def run_initialize
    @klass = Article
    @plural_sym = "articles"
    @instance_name = 'article'
    @instance_str = 'article'
    @instance_sym = "@article"
  end
end
