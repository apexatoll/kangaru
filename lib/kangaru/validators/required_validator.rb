module Kangaru
  module Validators
    class RequiredValidator < Validator
      MESSAGE = "can't be blank".freeze

      def validate
        return unless value_missing?

        add_error!(MESSAGE)
      end

      private

      def value_missing?
        value.nil? || value == "" || value == false
      end
    end
  end
end
