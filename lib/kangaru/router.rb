module Kangaru
  class Router
    using Patches::Inflections

    using Patches::Constantise

    class UndefinedControllerError < StandardError; end

    class UndefinedActionError < StandardError; end

    CONTROLLER_SUFFIX = "Controller".freeze

    attr_reader :command, :namespace

    def initialize(command, namespace: Object)
      @command   = command
      @namespace = namespace

      validate_controller_defined!
      validate_action_defined!
    end

    def resolve
      controller_class.new(command).execute
    end

    private

    def controller_name
      @controller_name ||= command.controller.to_class_name + CONTROLLER_SUFFIX
    end

    def controller_class
      @controller_class ||= controller_name.constantise(root: namespace)
    end

    def validate_controller_defined!
      return if namespace.const_defined?(controller_name)

      raise UndefinedControllerError,
            "#{controller_name} is not defined in #{namespace}"
    end

    def validate_action_defined!
      return if controller_class.instance_methods.include?(command.action)

      raise UndefinedActionError,
            "#{command.action} is not defined by #{controller_name}"
    end
  end
end
