module Kangaru
  class Controller
    attr_reader :command

    def initialize(command)
      @command = command
    end

    def renderer
      @renderer ||= Renderer.new(command.view_file)
    end

    def execute
      public_send(command.action)

      renderer.render(binding)
    end

    # The binding passed to the renderer is not scoped to the application
    # namespace, and as such, all application classes must be prefixed with the
    # namespace module. This change emulates the binding being created from
    # within the application namespace by delegating const lookups to said
    # namespace if the constant is not in scope from the current class.
    def self.const_missing(const)
      return super unless Kangaru.application.namespace.const_defined?(const)

      Kangaru.application.namespace.const_get(const)
    end

    private_class_method :const_missing
  end
end
