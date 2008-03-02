module ActionView
  module Helpers
    module JavaScriptHelper
      alias_method :orig_javascript_tag, :javascript_tag
      def javascript_tag(content, html_options={})
        if @config[:scripts_at_bottom]
          # TODO: it should be possible to include html_options into args, no?
          add_inline_scripts(content)
        else
          orig_javascript_tag(content, html_options)
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    alias_method :orig_create, :create
    def create(attributes = nil, validate=false)
      if attributes.is_a?(Array)
        attributes.collect { |attr| create(attr) }
      else
        object = new(attributes)
        validate ? object.save! : object.save
        object
      end
    end
  
    def create!(attributes=nil)
      create(attributes, true)
    end
  end
  
  def to_id; self[:id].to_i; end
  
  def internal_name(opts={})
    "#{self.class}(#{self[:id]})"
  end
end

class Fixnum
  def to_id; self; end;
end

# The following is to allow new Widget clips to have a null position column value upon
# creation.
ActiveRecord::Acts::List::InstanceMethods.class_eval do
  alias_method :orig_add_to_list_bottom, :add_to_list_bottom
  def add_to_list_bottom
    self[position_column] = bottom_position_in_list.to_i + 1 unless (self.new_record? && self.is_a?(Widget))
  end
  private :add_to_list_bottom
end

### AssetPackage to work with GIT
Synthesis::AssetPackage.class_eval do
  class << self
    def initialize(asset_type, package_hash)
      target_parts = self.class.parse_path(package_hash.keys.first)
      @target_dir = target_parts[1].to_s
      @target = target_parts[2].to_s
      @sources = package_hash[package_hash.keys.first]
      @asset_type = asset_type
      @asset_path = ($asset_base_path ? "#{$asset_base_path}/" : "#{RAILS_ROOT}/public/") +
          "#{@asset_type}#{@target_dir.gsub(/^(.+)$/, '/\1')}"
      @extension = get_extension
      # CHANGED: regexp changed to reflect GIT
      @match_regex = Regexp.new("\\A#{@target}_[0-9a-z]+.#{@extension}\\z")
    end
    
    def revision
      unless @revision
        if `git-show-ref -h HEAD` =~ /(.*?) .*?/
          @revision = $1
        end
      end
      @revision
    end
    private :revision
  end
end
