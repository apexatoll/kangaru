module Kangaru
  module Configurators
    BASE_CONFIGURATORS = [Configurator].freeze

    def self.classes
      constants.map    { |constant| const_get(constant) }
               .select { |constant| constant.is_a?(Class) }
               .reject { |constant| BASE_CONFIGURATORS.include?(constant) }
    end
  end
end
