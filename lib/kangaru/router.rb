module Kangaru
  class Router
    using Patches::Constantise

    class UndefinedControllerError < StandardError; end

    class UndefinedActionError < StandardError; end

    attr_reader :command, :namespace

    def initialize(command, namespace: Object)
      @command   = command
      @namespace = namespace

      validate_controller_defined!
      validate_action_defined!
    end

    private

    def controller_class
      @controller_class ||= command.controller.constantise(root: namespace)
    end

    def validate_controller_defined!
      return if namespace.const_defined?(command.controller)

      raise UndefinedControllerError,
            "#{command.controller} is not defined in #{namespace}"
    end

    def validate_action_defined!
      return if controller_class.instance_methods.include?(command.action)

      raise UndefinedActionError,
            "#{command.action} is not defined by #{command.controller}"
    end
  end
end
