module Kangaru
  module Configurators
    class Configurator
      include Concerns::AttributesConcern

      using Patches::Inflections

      def self.name
        to_s.gsub(/^.*::(?!.*::)/, "")
            .delete_suffix("Configurator")
            .to_snakecase
            .to_sym
      end

      def serialise
        self.class.attributes.to_h do |setting|
          [setting, send(setting)]
        end.compact
      end
    end
  end
end
