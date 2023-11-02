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
        load_validator(validator:, params:).validate
      end

      private

      def validator_name(validator)
        "#{validator.to_s.to_class_name}Validator"
      end

      def load_validator(validator:, params:)
        name = validator_name(validator)

        raise "#{name} is not defined" unless Validators.const_defined?(name)

        Validators.const_get(name).new(model:, attribute:, params:)
      end
    end
  end
end
