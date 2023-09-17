module Kangaru
  module InputParsers
    class InputParser
      attr_reader :tokens

      def initialize(tokens)
        @tokens = tokens
      end

      def parse
        raise NotImplementedError
      end
    end
  end
end
