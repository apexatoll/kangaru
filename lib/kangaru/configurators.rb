module Kangaru
  module Configurators
    def self.classes
      load_classes(self)
    end

    def self.load_classes(root)
      root.constants.map    { |const| root.const_get(const) }
                    .select { |const| const.is_a?(Class) }
    end

    private_class_method :load_classes
  end
end
