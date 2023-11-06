module Kangaru
  module Concerns
    module Validatable
      extend Concern

      class_methods do
        def validation_rules
          @validation_rules ||= {}
        end

        def validates(attribute, **validations)
          validation_rules[attribute] ||= {}
          validation_rules[attribute].merge!(**validations)
        end
      end

      def errors
        @errors ||= []
      end

      def validate
        self.class.validation_rules.each do |attribute, validations|
          validator = validator_for(attribute)

          validations.each do |validator_name, params|
            params = {} if params == true

            validator.validate(validator_name, **params)
          end
        end
      end

      def valid?
        validate

        errors.empty?
      end

      private

      def validator_for(attribute)
        Validation::AttributeValidator.new(model: self, attribute:)
      end
    end
  end
end
