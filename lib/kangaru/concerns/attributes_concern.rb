module Kangaru
  module Concerns
    module AttributesConcern
      extend Concern

      class_methods do
        def attributes
          instance_methods.grep(/\w=$/).map do |attribute|
            attribute.to_s.delete_suffix("=").to_sym
          end
        end
      end

      def initialize(**attributes)
        attributes.slice(*self.class.attributes).each do |attr, value|
          instance_variable_set(:"@#{attr}", value)
        end
      end
    end
  end
end
