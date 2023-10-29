module Kangaru
  class Command
    attr_reader :controller, :action, :arguments

    def initialize(controller:, action:, arguments:)
      @controller = controller
      @action = action
      @arguments = arguments
    end

    def self.parse(tokens)
      controller = LegacyInputParsers::ControllerParser.parse(tokens)
      action     = LegacyInputParsers::ActionParser.parse(tokens)
      arguments  = LegacyInputParsers::ArgumentParser.parse(tokens)

      new(controller:, action:, arguments:)
    end
  end
end
