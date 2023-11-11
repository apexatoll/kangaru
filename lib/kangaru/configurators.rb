module Kangaru
  module Configurators
    def self.classes
      load_classes(self) + load_classes(application_configurators)
    end

    def self.application_configurators
      Kangaru.application&.const_get(:Configurators)
    end

    def self.load_classes(root)
      return [] if root.nil?

      root.constants.map    { |const| root.const_get(const) }
                    .select { |const| const.is_a?(Class) }
    end

    private_class_method :application_configurators
    private_class_method :load_classes
  end
end
