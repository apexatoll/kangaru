module Kangaru
  class Controller
    extend Forwardable

    using Patches::Inflections

    SUFFIX = "Controller".freeze

    attr_reader :request

    def initialize(request)
      @request = request
    end

    def execute
      return unless public_send(request.action)

      renderer_for(request.action.to_s).render(binding)
    end

    # Returns the partial path for the controller based on the class name.
    # The first module namespace is removed as this is either Kangaru or the
    # target gem namespace. Used to infer the location of view files.
    def self.path
      name&.delete_suffix(SUFFIX)&.gsub(/^.*?::/, "")&.to_snakecase || raise
    end

    def_delegators :request, :params

    def target_id
      request.id
    end

    private

    def view_path(file)
      Kangaru.application!.view_path(self.class.path, file)
    end

    def renderer_for(file)
      Renderer.new(view_path(file))
    end

    # The binding passed to the renderer is not scoped to the application
    # namespace, and as such, all application classes must be prefixed with the
    # namespace module. This change emulates the binding being created from
    # within the application namespace by delegating const lookups to said
    # namespace if the constant is not in scope from the current class.
    def self.const_missing(const)
      return super unless Kangaru.application!.namespace.const_defined?(const)

      Kangaru.application!.namespace.const_get(const)
    end

    private_class_method :const_missing
  end
end
