module Kangaru
  class Renderer
    attr_reader :command

    def initialize(command)
      @command = command
    end

    def render(binding)
      return unless view_file.exist?

      puts ERB.new(view_file.read).result(binding)
    end

    private

    def view_file
      Kangaru.application.view_file(
        controller: command.controller,
        action: command.action.to_s
      )
    end
  end
end
