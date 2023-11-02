module Kangaru
  module Validation
    class AttributeValidator
      attr_reader :model, :attribute

      def initialize(model:, attribute:)
        @model = model
        @attribute = attribute
      end
    end
  end
end
