module Kangaru
  module Concerns
    module Configurable
      extend Concern

      using Patches::Inflections

      class_methods do
        def configurator_key
          (name || raise("class name not set"))
            .gsub(/^.*::/, "")
            .to_snakecase
            .to_sym
        end
      end

      def config
        Kangaru.application!.config[self.class.configurator_key] ||
          raise("inferred configurator not set by application")
      end
    end
  end
end
