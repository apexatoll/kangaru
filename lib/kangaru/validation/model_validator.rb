module Kangaru
  module Validation
    class ModelValidator
      attr_reader :model

      def initialize(model:)
        @model = model
      end

      def validate!(**rules)
        rules.each do |attribute, validations|
          validate_attribute!(attribute, validations)
        end
      end

      private

      def validate_attribute!(attribute, validations)
        load_attribute_validator(attribute).validate_all(**validations)
      end

      def load_attribute_validator(attribute)
        AttributeValidator.new(model:, attribute:)
      end
    end
  end
end
