module Kangaru
  module Initialiser
    def self.extended(namespace)
      source = caller[0].gsub(/:.*$/, "")

      Kangaru.application = Application.new(source:, namespace:)
      Kangaru.eager_load(Initialisers)

      namespace.extend Interface
    end
  end
end
