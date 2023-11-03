module Kangaru
  module Inflectors
    module InflectorMacros
      def inherited(child_class)
        instance_variables.each do |rule|
          value = instance_variable_get(rule)

          child_class.instance_variable_set(rule, value)
        end
      end

      def filter_input_with(pattern)
        @input_filter = pattern
      end

      def transform_tokens_with(symbol = nil, &block)
        @token_transformer = symbol || block
      end

      def join_tokens_with(joiner)
        @token_joiner = joiner
      end

      def join_groups_with(joiner)
        @group_joiner = joiner
      end

      def post_process_with(symbol = nil, &block)
        @post_processor = symbol || block
      end
    end
  end
end
