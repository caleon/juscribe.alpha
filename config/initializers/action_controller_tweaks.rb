module Mime
  EXTENSIONS = EXTENSION_LOOKUP.keys.map(&:intern)
end

ActionController::Base.class_eval { alias_method :orig_respond_to, :respond_to }
module MimeRespondsAddendum
  def respond_to(*types, &block)
    raise ArgumentError, "respond_to takes either types or a block, never both" unless types.any? ^ block
    block ||= lambda { |responder| types.each { |type| responder.send(type);  } }
    responder = ActionController::MimeResponds::Responder.new(self)
    block.call(responder)
    @responding_types = responder.instance_variable_get(:@order).map(&:to_sym) # CHANGED
    responder.respond
  end
end
ActionController::Base.send(:include, MimeRespondsAddendum)
