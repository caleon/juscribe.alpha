class ApplicationController < ActionController::Base
  
  ######################################################################
  ##                                                                  ##
  ##    A P P L I C A T I O N    S E T U P                            ##
  ##                                                                  ##
  ######################################################################
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => 'a241500281274090ecdf656d5074d028'
  filter_parameter_logging :password, :password_confirmation
  before_filter :load_config, :get_viewer
  helper :all  
  layout 'standard'
  
  private
  def load_config
    # TODO: set up a special table where a "recheck" value can be toggled. This
    # filter will check that value each time and if it is TRUE, it'll re-load the
    # data from the yaml file. Perhaps use a "last_checked_at" column so that
    # under normal conditions, the app will automatically recheck the yaml file
    # after a certain period of time.
    @config = SITE
  end
    
  def get_viewer
    @viewer ||= (User.find(session[:id]) rescue nil) if session[:id]
  end
  
  def get_find_opts(hash={})
    params[:page] ||= 1
    limit, page = 20, params[:page].to_i
    offset = (page -1) * limit
    return { :limit => limit, :offset => offset }.merge(hash)
  end

  
  ######################################################################
  ##                                                                  ##
  ##    P I C T U R E    H A N D L I N G                              ##
  ##                                                                  ##
  ######################################################################
  
  def create_uploaded_picture_for(record, opts={})
    raise unless picture_uploaded? && !record.nil? && (record.respond_to?(:pictures) || record.respond_to?(:picture))
    params[:picture].merge!(:user => get_viewer || opts[:user])
    if !opts[:save]
      picture = record.pictures.new(params[:picture]) rescue record.picture.new(params[:picture])
      return picture
    end
    if record.pictures.create(params[:picture])
      msg = "Your picture has been uploaded."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to opts[:redirect_to] || edit_picture_url(picture) }
        format.js { flash.now[:notice] = msg }
      end if opts[:respond]
      # Now go to end of method to return picture back to original controller.
      # The above may not work because the respond_to is not setup like display_error with its instance_eval.
    else
      flash.now[:warning] = "Sorry, could not save the uploaded picture. Please upload another picture."
      record.errors.add(:picture, "could not be saved because " + picture.errors.full_messages.join(', '))
      return false
    end
    return picture # needs to be saved elsewhere then.
  end
  
  def picture_uploaded?
    params[:picture] && !params[:picture][:uploaded_data].blank?
  end
  
end
