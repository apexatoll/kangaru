module Kangaru
  class InputParser
    ARGUMENT_TOKEN = /^--?/

    attr_reader :tokens

    def initialize(*tokens)
      @tokens = tokens
    end

    def parse
      Command.new(**command_attributes)
    end

    private

    def command_attributes
      {
        path: route_attributes[:path],
        action: route_attributes[:action],
        id: route_attributes[:id],
        arguments:
      }
    end

    def route_tokens
      tokens.take_while { |token| !token.match?(ARGUMENT_TOKEN) }
    end

    def argument_tokens
      tokens.drop_while { |token| !token.match?(ARGUMENT_TOKEN) }
    end

    def route_attributes
      InputParsers::RouteParser.new(*route_tokens).parse
    end

    def arguments
      ArgumentParser.new(*argument_tokens).parse
    end
  end
end
