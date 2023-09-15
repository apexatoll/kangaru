module Kangaru
  module Inflectors
    class Inflector
      attr_reader :tokeniser

      def initialize(string)
        @tokeniser = Tokeniser.new(string)
      end

      def inflect
        tokeniser.split.map do |tokens|
          tokens.map! { |token| transform_token(token) }

          join_tokens(tokens)
        end.join
      end

      private

      def class_attribute(key)
        self.class.instance_variable_get(:"@#{key}")
      end

      def token_transformer
        class_attribute(:token_transformer)
      end

      def token_joiner
        class_attribute(:token_joiner)
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
    end
  end
end
