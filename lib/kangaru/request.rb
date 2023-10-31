module Kangaru
  class Request
    using Patches::Inflections

    DEFAULT_CONTROLLER = "DefaultController".freeze

    CONTROLLER_SUFFIX = "Controller".freeze

    attr_reader :path, :params

    def initialize(path:, params:)
      @path = path
      @params = params
    end

    def controller
      return DEFAULT_CONTROLLER if path_parser.controller.nil?

      path_parser.controller&.to_class_name&.concat(CONTROLLER_SUFFIX) || raise
    end

    private

    def path_parser
      @path_parser ||= PathParser.new(path)
    end
  end
end
