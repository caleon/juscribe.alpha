module MetaTagHelper
  class MetaAbstract
    def initialize(*args)
      @options = args.extract_options!
      @content = args.shift
    end
    
    def content; @content; end
    def has_content?; !@content.nil?; end
    def options; @options; end
  end
  
  def meta_author_tag; tagarize_meta metas[:author]; end
  def set_meta_author!(author)
    set_meta!(:author, :content => author.display_name)
  end  
  
  def meta_description_tag; tagarize_meta metas[:description]; end
  def set_meta_description!(desc)
    set_meta!(:description, :content => desc)
  end
    
  def meta_keywords_tag; tagarize_meta metas[:keywords]; end
  def set_meta_keywords!(*keywords)
    @meta_keywords = keywords
    set_meta!(:keywords, :content => meta_keywords_array.compact.join(', '))
  end
  def add_meta_keyword!(keyword)
    @meta_keywords << keyword
    set_meta!(:keywords, :content => meta_keywords_array.compact.join(', '))
  end

  def meta_tags; tagarize_meta(*metas.values); end
  

  def metas
    @meta_hash ||= {}
  end
  
  def meta_keywords_array
    @meta_keywords ||= []
  end
  
  def set_meta!(kind, opts={})
    metas[kind] = MetaAbstract.new(opts.merge(:name => kind.to_s))
  end
  
  def tagarize_meta(*meta_abstracts)
    meta_abstracts.compact.map {|ma| content_tag(:meta, ma.content, ma.options) }.join("\r\n")
  end   
end