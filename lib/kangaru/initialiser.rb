module Kangaru
  module Initialiser
    def self.extended(namespace)
      root_file = caller[0].gsub(/:.*$/, "")

      Kangaru.application = Application.new(root_file:, namespace:).tap(&:setup)
    end
  end
end
