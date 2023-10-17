module Kangaru
  module Configurators
    # These are not set as accessors by Config instances as they are abstract.
    BASE_CONFIGURATORS = [Configurator, OpenConfigurator].freeze

    def self.classes
      constants.map    { |constant| const_get(constant) }
               .select { |constant| constant.is_a?(Class) }
               .reject { |constant| BASE_CONFIGURATORS.include?(constant) }
    end
  end
end
