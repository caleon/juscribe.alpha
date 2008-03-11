class WidgetsController < ApplicationController
  use_shared_options
  
  def place
    return unless setup
  end
  
  def unplace
    return unless setup
  end
  
  private
  def setup(includes=nil, error_opts={})
    @user = User.primary_find(params[:user_id])
    @widget = @user.clips.find(params[:id], :include => includes)
    true && authorize(@widget)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That User/Widget could not be found. Please check the URL."
    display_error(error_opts)
    false
  end
end
