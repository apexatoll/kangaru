module Kangaru
  class Command
    attr_reader :controller, :action, :arguments

    def initialize(controller:, action:, arguments:)
      @controller = controller
      @action = action
      @arguments = arguments
    end

    def self.from_argv(tokens)
      controller = InputParsers::ControllerParser.parse(tokens)
      action     = InputParsers::ActionParser.parse(tokens)
      arguments  = InputParsers::ArgumentParser.parse(tokens)

      new(controller:, action:, arguments:)
    end
  end
end
