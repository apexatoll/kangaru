module Kangaru
  class Router
    using Patches::Inflections
    using Patches::Constantise

    attr_reader :request, :namespace

    def initialize(namespace: Object)
      @namespace = namespace
    end

    def resolve(request)
      @request = request

      validate_controller_defined!
      validate_action_defined!

      controller_class.new(request).execute
    end

    private

    def controller_class
      request.controller.constantise(root: namespace)
    end

    def validate_controller_defined!
      return if namespace.const_defined?(request.controller)

      raise "#{request.controller} is not defined in #{namespace}"
    end

    def validate_action_defined!
      return if controller_class.instance_methods.include?(request.action)

      raise "#{request.action} is not defined by #{request.controller}"
    end
  end
end
