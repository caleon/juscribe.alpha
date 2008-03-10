class CommentsController < ApplicationController

  private
  # Overriding default setup method in ApplicationController
  def setup(includes=nil, error_opts={})
    return unless get_commentable
    @object = @commentable.comments.find(params[:id], :include => includes)
    set_model_instance(@object)
    true && authorize(@object)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Comment could not be found. Please check the address."
    display_error(error_opts) # Error will only have access to @object from the setup method.
    false
  end
  
  # Method sets @widgetable based on param keys, or if not found, displays error.
  def get_commentable(opts={})
    return unless commentable_id_key = params.keys.detect{|key| key.to_s.match(/_id$/)}
    commentable_class = commentable_id_key.to_s.gsub(/_id$/, '').classify.constantize
    @commentable = commentable_class.primary_find(params[commentable_id_key])
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{commentable_class} does not have the clip you requested.")
    false
  end
end
