module Kangaru
  class Router
    extend Forwardable

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

    def_delegators :command, :controller_name, :action

    def controller_class
      @controller_class ||= command.controller_name.constantise(root: namespace)
    end

    def validate_controller_defined!
      return if namespace.const_defined?(controller_name)

      raise "#{controller_name} is not defined in #{namespace}"
    end

    def validate_action_defined!
      return if controller_class.instance_methods.include?(action)

      raise "#{action} is not defined by #{controller_name}"
    end
  end
end
