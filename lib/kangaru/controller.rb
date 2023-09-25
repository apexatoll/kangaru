module Kangaru
  class Controller
    attr_reader :command, :renderer

    def initialize(command)
      @command = command
      @renderer = Renderer.new(command)
    end

    def execute
      public_send(command.action)

      renderer.render(binding)
    end
  end
end
