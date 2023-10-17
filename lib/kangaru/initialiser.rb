module Kangaru
  module Initialiser
    module InjectedMethods
      def run!(argv)
        Kangaru.application.run!(argv)
      end
    end

    def self.extended(namespace)
      source = caller[0].gsub(/:.*$/, "")

      Kangaru.application = Application.new(source:, namespace:)

      namespace.extend InjectedMethods
    end
  end
end
