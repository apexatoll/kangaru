module Kangaru
  module InputParsers
    class InputParser
      ARGUMENT_TOKEN = /^-/

      attr_reader :tokens

      def initialize(tokens)
        @tokens = tokens
      end

      def parse
        raise NotImplementedError
      end

      def command_tokens
        tokens.take_while { |token| !token.match?(ARGUMENT_TOKEN) }
      end

      def argument_tokens
        tokens.drop_while { |token| !token.match?(ARGUMENT_TOKEN) }
      end
    end
  end
end
