module ActiveRecord
  module Acts
    module Widgetable
      module InstanceMethods
        def picture
          self.pictures.first
        rescue
          self.picture.first rescue nil
        end
      end
    end
  end
end