module Kangaru
  module Initialiser
    def self.extended(namespace)
      root_file = caller[0].gsub(/:.*$/, "")

      Kangaru.application = Application.from_callsite(root_file, namespace:)

      namespace.module_eval do
        def self.run!(argv)
          Kangaru.application.run!(argv)
        end
      end
    end
  end
end
