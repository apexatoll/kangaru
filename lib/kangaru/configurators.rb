module Kangaru
  module Configurators
    def self.classes
      constants.map    { |constant| const_get(constant) }
               .select { |constant| constant.is_a?(Class) }
               .reject { |constant| constant == BaseConfigurator }
    end
  end
end
