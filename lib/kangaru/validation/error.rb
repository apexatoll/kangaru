module Kangaru
  module Validation
    class Error
      attr_reader :attribute, :type

      def initialize(attribute:, type:)
        @attribute = attribute
        @type = type
      end
    end
  end
end
