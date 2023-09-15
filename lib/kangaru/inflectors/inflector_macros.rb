module Kangaru
  module Inflectors
    module InflectorMacros
      def transform_tokens_with(symbol = nil, &block)
        @token_transformer = symbol || block
      end

      def join_tokens_with(joiner)
        @token_joiner = joiner
      end

      def join_groups_with(joiner)
        @group_joiner = joiner
      end
    end
  end
end
