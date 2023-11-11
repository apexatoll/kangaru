module Kangaru
  module Configurators
    # These are not set as accessors by Config instances as they are abstract.
    BASE_CONFIGURATORS = [OpenConfigurator].freeze

    def self.classes
      load_classes(self)
    end

    def self.load_classes(root)
      root.constants.map    { |const| root.const_get(const) }
                    .select { |const| const.is_a?(Class) }
                    .reject { |const| BASE_CONFIGURATORS.include?(const) }
    end

    private_class_method :load_classes
  end
end
