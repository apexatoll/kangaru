module Kangaru
  class Request
    using Patches::Inflections

    include Concerns::Configurable

    DEFAULT_CONTROLLER = "DefaultController".freeze

    DEFAULT_ACTION = :default

    attr_reader :path, :params

    def initialize(path:, params:)
      @path = path
      @params = params
    end

    def controller
      return DEFAULT_CONTROLLER if path_parser.controller.nil?

      path_parser.controller&.to_class_name&.concat(Controller::SUFFIX) || raise
    end

    def action
      path_parser.action || DEFAULT_ACTION
    end

    private

    def path_parser
      @path_parser ||= PathParser.new(path)
    end
  end
end
