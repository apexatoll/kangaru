module Kangaru
  module Concerns
    module Configurable
      extend Concern

      using Patches::Constantise
      using Patches::Inflections

      class_methods do
        def configurator_name
          (name || raise("class name not set"))
            .gsub(/^(.*?)::/, "\\1::Configurators::")
            .concat("Configurator")
        end

        def configurator_key
          (name || raise("class name not set"))
            .gsub(/^.*::/, "")
            .to_snakecase
            .to_sym
        end
      end

      def config
        Kangaru.application!.config.for(self.class.configurator_name) ||
          raise("inferred configurator not set by application")
      end
    end
  end
end
