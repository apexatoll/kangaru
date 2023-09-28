module Kangaru
  class Config
    attr_reader :configurators

    def initialize
      @configurators = set_configurators!
    end

    private

    def set_configurators!
      Configurators.classes.to_h do |configurator_class|
        self.class.class_eval { attr_reader configurator_class.name }

        configurator = configurator_class.new

        instance_variable_set(:"@#{configurator_class.name}", configurator)

        [configurator_class.name, configurator]
      end
    end
  end
end
