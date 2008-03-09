class ArticlesController < ApplicationController  
  def initialize(*args)
    @klass = Article
    @plural_sym = "articles"
    @instance_name = 'article'
    @instance_str = 'article'
    @instance_sym = "@article"
  end
end
