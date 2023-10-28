module Kangaru
  class Renderer
    attr_reader :command

    def initialize(command)
      @command = command
    end

    def render(binding)
      return unless view_path.exist?

      ERB.new(view_path.read).run(binding)
    end

    private

    def view_path
      Kangaru.application.view_path(
        controller: command.controller,
        action: command.action.to_s
      )
    end
  end
end
