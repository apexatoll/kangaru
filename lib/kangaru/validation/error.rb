module Kangaru
  module Validation
    class Error
      using Patches::Inflections

      attr_reader :attribute, :message

      def initialize(attribute:, message:)
        @attribute = attribute
        @message = message
      end

      def full_message
        [human_attribute, message].join(" ")
      end

      private

      def human_attribute
        attribute.to_s.to_humanised
      end
    end
  end
end
