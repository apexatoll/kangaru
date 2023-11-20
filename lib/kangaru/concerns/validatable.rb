module Kangaru
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
      model_validator.validate!(**self.class.validation_rules)
    end

    def valid?
      validate

      errors.empty?
    end

    private

    def model_validator
      @model_validator ||= Validation::ModelValidator.new(model: self)
    end
  end
end
