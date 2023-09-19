module Kangaru
  module Inflectors
    class Constantiser
      using Patches::Inflections

      def self.constantise(string)
        as_class    = string.to_class_name
        as_constant = string.to_constant_name

        if Object.const_defined?(as_class)
          Object.const_get(as_class)
        elsif Object.const_defined?(as_constant)
          Object.const_get(as_constant)
        end
      end
    end
  end
end
