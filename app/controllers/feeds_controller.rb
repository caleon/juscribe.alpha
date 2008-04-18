class FeedsController < ApplicationController
  def latest
    return nil if params[:url].blank?
    # TODO: Validate url with regexp
    render :partial => "items/feed", :locals => { :url => params[:url] }
  end
end
