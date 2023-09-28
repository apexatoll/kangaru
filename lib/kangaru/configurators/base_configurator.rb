module Kangaru
  module Configurators
    class BaseConfigurator
      using Patches::Inflections

      def self.name
        to_s.gsub(/^.*::(?!.*::)/, "")
            .delete_suffix("Configurator")
            .to_snakecase
            .to_sym
      end

      def self.settings
        @settings ||= instance_methods.grep(/\w=$/).map do |setting|
          setting.to_s.delete_suffix("=").to_sym
        end
      end

      def serialise
        self.class.settings.to_h do |setting|
          [setting, send(setting)]
        end.compact
      end
    end
  end
end
