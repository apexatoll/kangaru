module Kangaru
  class Router
    using Patches::Inflections

    using Patches::Constantise

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
      command.controller_name
    end

    def controller_class
      @controller_class ||= controller_name.constantise(root: namespace)
    end

    def validate_controller_defined!
      return if namespace.const_defined?(controller_name)

      raise "#{controller_name} is not defined in #{namespace}"
    end

    def validate_action_defined!
      return if controller_class.instance_methods.include?(command.action)

      raise "#{command.action} is not defined by #{controller_name}"
    end
  end
end
