module Kangaru
  module Configurators
    class BaseConfigurator
      def self.settings
        @settings ||= instance_methods.grep(/\w=$/).map do |setting|
          setting.to_s.delete_suffix("=").to_sym
        end
      end
    end
  end
end
