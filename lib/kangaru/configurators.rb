module Kangaru
  module Configurators
    def self.classes
      constants.map    { |constant| const_get(constant) }
               .select { |constant| constant.is_a?(Class) }
               .reject { |constant| constant == Configurator }
    end
  end
end
