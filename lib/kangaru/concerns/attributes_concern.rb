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

        def set_default(**attributes)
          defaults.merge!(**attributes)
        end

        def defaults
          @defaults ||= {}
        end
      end

      def initialize(**attributes)
        attributes = self.class.defaults.merge(**attributes)

        attributes.slice(*self.class.attributes).each do |attr, value|
          instance_variable_set(:"@#{attr}", value)
        end
      end

      def merge!(**attributes)
        attributes.slice(*self.class.attributes).each do |attr, value|
          instance_variable_set(:"@#{attr}", value)
        end
      end
    end
  end
end
