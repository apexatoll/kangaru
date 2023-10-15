module Kangaru
  module Initialiser
    def self.extended(namespace)
      source = caller[0].gsub(/:.*$/, "")

      Kangaru.application = Application.new(source:, namespace:)

      namespace.module_eval do
        def self.run!(argv)
          Kangaru.application.run!(argv)
        end
      end
    end
  end
end
