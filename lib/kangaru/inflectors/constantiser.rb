module Kangaru
  module Inflectors
    class Constantiser
      using Patches::Inflections

      attr_reader :string

      def initialize(string)
        @string = string
      end

      def constantise
        if defined_as_class?
          Object.const_get(string.to_class_name)
        elsif defined_as_constant?
          Object.const_get(string.to_constant_name)
        end
      end

      def self.constantise(string)
        new(string).constantise
      end

      private

      def defined_as_class?
        Object.const_defined?(string.to_class_name)
      end

      def defined_as_constant?
        Object.const_defined?(string.to_constant_name)
      end
    end
  end
end
