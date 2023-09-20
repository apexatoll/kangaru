module Kangaru
  class Controller
    attr_reader :command

    def initialize(command)
      @command = command
    end
  end
end
