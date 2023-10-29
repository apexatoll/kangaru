module Kangaru
  class Command
    using Patches::Inflections

    DEFAULT_PATH = "default".freeze

    DEFAULT_ACTION = :default

    CONTROLLER_SUFFIX = "controller".freeze

    attr_reader :id, :arguments

    def initialize(path:, action:, id:, arguments:)
      @path = path
      @action = action
      @id = id
      @arguments = arguments
    end

    def path
      @path || DEFAULT_PATH
    end

    def action
      @action || DEFAULT_ACTION
    end

    def controller_name
      [path, CONTROLLER_SUFFIX].join("_").to_class_name
    end

    def view_file
      Kangaru.application.view_path(path, action.to_s)
    end

    def self.parse(tokens)
      InputParser.new(*tokens).parse
    end
  end
end
