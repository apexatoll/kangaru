module Kangaru
  module Validation
    class AttributeValidator
      using Patches::Inflections

      attr_reader :model, :attribute

      def initialize(model:, attribute:)
        @model = model
        @attribute = attribute
      end

      def validate(validator, **params)
        load_validator(validator:, **params).validate
      end

      private

      def load_validator(validator:, **params)
        Validators.get(validator).new(model:, attribute:, **params)
      end
    end
  end
end
