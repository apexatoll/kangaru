module Kangaru
  module Validation
    class Error
      using Patches::Inflections

      MESSAGES = {
        blank: "can't be blank"
      }.freeze

      attr_reader :attribute, :type

      def initialize(attribute:, type:)
        @attribute = attribute
        @type = type
      end

      def full_message
        [human_attribute, message].join(" ")
      end

      private

      def human_attribute
        attribute.to_s.to_humanised
      end

      def message
        MESSAGES[type] || raise("invalid message type")
      end
    end
  end
end
