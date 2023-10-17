module Kangaru
  module Initialiser
    module InjectedMethods
      def run!(argv)
        Kangaru.application.run!(argv)
      end

      def config
        Kangaru.application.config
      end

      def configure(&)
        Kangaru.application.configure(&)
      end

      def database
        Kangaru.application.database
      end
    end

    def self.extended(namespace)
      source = caller[0].gsub(/:.*$/, "")

      Kangaru.application = Application.new(source:, namespace:)

      namespace.extend InjectedMethods
    end
  end
end
