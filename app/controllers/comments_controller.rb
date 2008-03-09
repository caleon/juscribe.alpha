class CommentsController < ApplicationController
  
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
    @klass = Comment
    @plural_sym = "comments"
    @instance_name = 'comment'
    @instance_str = 'comment'
    @instance_sym = "@comment"
  end
end
