module Kangaru
  module LegacyInputParsers
    class ArgumentParser < InputParser
      using Patches::Inflections

      def parse
        grouped_argument_tokens.to_h do |tokens|
          key   = parse_key(tokens.shift || raise)
          value = parse_value(tokens)

          [key, value]
        end
      end

      private

      def grouped_argument_tokens
        argument_tokens.slice_before(ARGUMENT_TOKEN).to_a
      end

      def parse_key(key)
        key.gsub(/^-+/, "").to_snakecase.to_sym
      end

      def parse_value(tokens)
        tokens.empty? || tokens.join(" ")
      end
    end
  end
end
