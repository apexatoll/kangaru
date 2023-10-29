module Kangaru
  module InputParsers
    class RouteParser
      using Patches::Inflections

      attr_reader :tokens

      def initialize(*tokens)
        @tokens = tokens
      end

      def parse
        tokens.dup.tap do |tokens|
          @id     = tokens.pop if id_token_set?
          @action = tokens.pop
          @path   = tokens.join("/") unless tokens.empty?
        end

        attributes
      end

      private

      def attributes
        { path:, action:, id: }
      end

      def id_token_set?
        tokens.last&.match?(/^\d+$/) == true
      end

      def path
        @path&.to_snakecase
      end

      def action
        @action&.to_sym
      end

      def id
        @id&.to_i
      end
    end
  end
end
