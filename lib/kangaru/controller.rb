module Kangaru
  class Controller
    attr_reader :command

    def initialize(command)
      @command = command
    end

    def execute
      public_send(command.action)
    end
  end
end
