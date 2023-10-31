module Kangaru
  class ArgumentParser
    using Patches::Inflections

    attr_reader :tokens

    def initialize(*tokens)
      @tokens = tokens
    end

    def parse
      grouped_argument_tokens.to_h do |tokens|
        key   = parse_key(tokens.shift || raise)
        value = parse_value(tokens)

        [key, value]
      end
    end

    private

    def grouped_argument_tokens
      tokens.slice_before(/^-/).to_a
    end

    def parse_key(key)
      key.gsub(/^-+/, "").to_snakecase.to_sym
    end

    def parse_value(tokens)
      tokens.empty? || tokens.join(" ")
    end
  end
end
