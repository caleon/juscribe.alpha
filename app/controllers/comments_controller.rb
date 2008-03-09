class CommentsController < ApplicationController
  def initialize(*args)
    @klass = Comment
    @plural_sym = "comments"
    @instance_name = 'comment'
    @instance_str = 'comment'
    @instance_sym = "@comment"
  end
end
