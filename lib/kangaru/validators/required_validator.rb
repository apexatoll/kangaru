module Kangaru
  module Validators
    class RequiredValidator < Validator
      def validate
        return unless value_missing?

        add_error!(:blank)
      end

      private

      def value_missing?
        value.nil? || value == "" || value == false
      end
    end
  end
end
