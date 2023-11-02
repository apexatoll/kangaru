module Kangaru
  module Validators
    class Validator
      attr_reader :model, :attribute, :params, :value

      def initialize(model:, attribute:, params:)
        @model = model
        @attribute = attribute
        @params = params
        @value = model.public_send(attribute)
      end

      def validate
        raise NotImplementedError
      end
    end
  end
end
