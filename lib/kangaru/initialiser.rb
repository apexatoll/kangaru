module Kangaru
  module Initialiser
    def self.extended(namespace)
      root_file = caller[0].gsub(/:.*$/, "")

      name = File.basename(root_file).gsub(/\.[^\.]*$/, "")
      dir  = File.dirname(root_file).gsub(%r{/#{name}/lib}, "")

      Kangaru.application = Application.new(dir:, name:, namespace:)
                                       .tap(&:setup)

      namespace.module_eval do
        def self.run!(argv)
          Kangaru.application.run!(argv)
        end
      end
    end
  end
end
