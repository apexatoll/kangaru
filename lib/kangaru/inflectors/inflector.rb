module Kangaru
  module Inflectors
    class Inflector
      extend InflectorMacros

      DEFAULT_GROUP_JOINER = "/".freeze

      attr_reader :string

      def initialize(string)
        @string = string
      end

      def inflect
        join_groups(
          transform_and_join_tokens(tokeniser.split)
        )
      end

      private

      def tokeniser
        @tokeniser ||= Tokeniser.new(string)
      end

      def class_attribute(key)
        self.class.instance_variable_get(:"@#{key}")
      end

      def token_transformer
        class_attribute(:token_transformer)
      end

      def token_joiner
        class_attribute(:token_joiner)
      end

      def group_joiner
        class_attribute(:group_joiner) || DEFAULT_GROUP_JOINER
      end

      def transform_and_join_tokens(token_groups)
        token_groups.map do |tokens|
          join_tokens(
            tokens.map { |token| transform_token(token) }
          )
        end
      end

      def transform_token(token)
        case token_transformer
        when Proc   then token_transformer.call(token)
        when Symbol then token.send(token_transformer)
        else token
        end
      end

      def join_tokens(tokens)
        tokens.join(token_joiner)
      end

      def join_groups(words)
        words.join(group_joiner)
      end
    end
  end
end
