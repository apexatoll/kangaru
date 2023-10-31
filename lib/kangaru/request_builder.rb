module Kangaru
  class RequestBuilder
    ARGUMENT_TOKEN = /^--?/

    attr_reader :tokens

    def initialize(tokens)
      @tokens = tokens
    end

    def build
      Request.new(path:, params:)
    end

    private

    def path
      File.join(*path_tokens).prepend("/")
    end

    def params
      ArgumentParser.new(*param_tokens).parse
    end

    def path_tokens
      tokens.take_while { |token| !token.match?(ARGUMENT_TOKEN) }
    end

    def param_tokens
      tokens.drop_while { |token| !token.match?(ARGUMENT_TOKEN) }
    end
  end
end
