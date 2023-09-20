module Kangaru
  module Inflectors
    class Constantiser
      using Patches::Inflections

      def self.constantise(string, root: Object)
        as_class    = string.to_class_name
        as_constant = string.to_constant_name

        if root.const_defined?(as_class)
          root.const_get(as_class)
        elsif root.const_defined?(as_constant)
          root.const_get(as_constant)
        end
      end
    end
  end
end
