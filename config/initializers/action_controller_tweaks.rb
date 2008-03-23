module ActionController
  module Resources
    class Resource #:nodoc:
      def path; @path ||= @options[:special_path] || "#{path_prefix}/#{@options[:custom_path] || plural}"; end
    end
  end
  
  
  module MimeResponds::InstanceMethods
    def respond_to_with_type_registration(*types, &block)
      raise ArgumentError, "respond_to takes either types or a block, never both" unless types.any? ^ block
      block ||= lambda { |responder| types.each { |type| responder.send(type);  } }
      responder = ActionController::MimeResponds::Responder.new(self)
      block.call(responder)
      @responding_types = responder.instance_variable_get(:@order).map(&:to_sym) # CHANGED
      responder.respond
    end
    alias_method_chain :respond_to, :type_registration
  end
end

module Mime
  EXTENSIONS = EXTENSION_LOOKUP.keys.map(&:intern)
end
