module Kangaru
  class Request
    using Patches::Inflections

    include Configurable

    DEFAULT_CONTROLLER = "DefaultController".freeze

    DEFAULT_ACTION = :default

    attr_reader :path, :params

    def initialize(path:, params:)
      @path = path
      @params = params
    end

    def controller
      return default_controller if path_parser.controller.nil?

      path_parser.controller&.to_class_name&.concat(Controller::SUFFIX) || raise
    end

    def action
      path_parser.action || DEFAULT_ACTION
    end

    private

    def path_parser
      @path_parser ||= PathParser.new(path)
    end

    def default_controller
      return DEFAULT_CONTROLLER if config.default_controller.nil?

      config.default_controller.to_s
    end
  end
end
