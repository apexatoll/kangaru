module Kangaru
  class Configurator
    include Attributable
    include Validatable

    using Patches::Inflections

    def self.key
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
