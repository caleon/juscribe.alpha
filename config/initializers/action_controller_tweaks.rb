module ActionController
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
  #module Routing
  #  module Optimisation
  #    class PositionalArguments < Optimiser
  #      def generation_code
  #        elements = []
  #        idx = 0
  #
  #        if kind == :url
  #          elements << '#{request.protocol}'
  #          elements << '#{request.host_with_port}'
  #        end
  #
  #        elements << '#{request.relative_url_root if request.relative_url_root}'
  #
  #        # The last entry in route.segments appears to # *always* be a
  #        # 'divider segment' for '/' but we have assertions to ensure that
  #        # we don't include the trailing slashes, so skip them.
  #        (route.segments.size == 1 ? route.segments : route.segments[0..-2]).each do |segment|
  #          if segment.is_a?(DynamicSegment)
  #            elements << segment.interpolation_chunk("args[#{idx}].to_param")
  #            idx += 1
  #          else
  #            elements << segment.interpolation_chunk
  #          end
  #        end
  #        %("#{elements.flatten * ''}")
  #      end # end generation_code
  #    end
  #  end
  #end
end

module Mime
  EXTENSIONS = EXTENSION_LOOKUP.keys.map(&:intern)
end
