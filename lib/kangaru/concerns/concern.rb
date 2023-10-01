module Kangaru
  module Concerns
    module Concern
      def append_features(base)
        super
        evaluate_concern_blocks!(base)
      end

      def class_methods(&)
        if const_defined?(:ClassMethods)
          const_get(:ClassMethods)
        else
          const_set(:ClassMethods, Module.new)
        end.module_eval(&)
      end

      def included(base = nil, &block)
        super base if base
        return if block.nil?

        @included = block
      end

      private

      def evaluate_concern_blocks!(base)
        base.extend(const_get(:ClassMethods)) if const_defined?(:ClassMethods)

        base.class_eval(&@included) if instance_variable_defined?(:@included)
      end
    end
  end
end
