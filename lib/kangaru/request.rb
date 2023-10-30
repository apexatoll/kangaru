module Kangaru
  class Request
    attr_reader :path, :params

    def initialize(path:, params:)
      @path = path
      @params = params
    end
  end
end
