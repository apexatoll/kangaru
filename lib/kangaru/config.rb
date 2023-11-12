module Kangaru
  class Config
    using Patches::Symboliser

    attr_reader :configurators

    def initialize
      @configurators = set_configurators!
    end

    def serialise
      configurators.transform_values(&:serialise)
    end

    def import!(path)
      read_external_config(path).each do |key, config|
        configurators[key]&.merge!(**config)
      end
    end

    # Returns the configurator instance with the given class name.
    def for(configurator_name)
      configurators.values.find do |configurator|
        configurator.class.name == configurator_name # rubocop:disable Style
      end
    end

    private

    def set_configurators!
      Configurators.classes.to_h do |configurator_class|
        self.class.class_eval { attr_reader configurator_class.key }

        configurator = configurator_class.new

        instance_variable_set(:"@#{configurator_class.key}", configurator)

        [configurator_class.key, configurator]
      end
    end

    def read_external_config(path)
      return {} unless File.exist?(path)

      YAML.load_file(path)&.symbolise || {}
    end
  end
end
