module Kangaru
  class InputParser
    ARGUMENT_TOKEN = /^--?/

    attr_reader :tokens

    def initialize(*tokens)
      @tokens = tokens
    end

    def parse
      route.merge(arguments:)
    end

    private

    def route_tokens
      tokens.take_while { |token| !token.match?(ARGUMENT_TOKEN) }
    end

    def argument_tokens
      tokens.drop_while { |token| !token.match?(ARGUMENT_TOKEN) }
    end

    def route
      InputParsers::RouteParser.new(*route_tokens).parse
    end

    def arguments
      InputParsers::ArgumentParser.new(*argument_tokens).parse
    end
  end
end
