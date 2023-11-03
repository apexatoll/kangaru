module Kangaru
  module Concerns
    module Validatable
      extend Concern

      class_methods do
        def validations
          @validations ||= {}
        end
      end

      def errors
        @errors ||= []
      end

      def validate
        self.class.validations.each do |attribute, validations|
          validator = validator_for(attribute)

          validations.each do |validator_name, params|
            params = {} if params == true

            validator.validate(validator_name, **params)
          end
        end
      end

      private

      def validator_for(attribute)
        Validation::AttributeValidator.new(model: self, attribute:)
      end
    end
  end
end
