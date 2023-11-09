# Similar to a standard configurator, except on initialisation, it will set
# accessors for every attribute specified. This means that the super call will
# lead to each value being set as if the accessor was defined in the class.
module Kangaru
  module Configurators
    class OpenConfigurator < Configurator
      using Patches::Symboliser

      def initialize(**)
        set_accessors!(**)

        super
      end

      # Import contents of a yaml file
      def self.from_yaml_file(path)
        raise "path does not exist" unless File.exist?(path)

        attributes = YAML.load_file(path)&.symbolise || {}

        new(**attributes)
      end

      private

      def set_accessors!(**attributes)
        attributes.each_key do |key|
          self.class.class_eval { attr_accessor key }
        end
      end
    end
  end
end
