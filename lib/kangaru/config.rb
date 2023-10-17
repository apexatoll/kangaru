module Kangaru
  class Config
    attr_reader :configurators

    def initialize
      @configurators = set_configurators!
    end

    def serialise
      configurators.transform_values(&:serialise)
    end

    def import_external_config!
      return unless external_config_exists?

      @external = Configurators::ExternalConfigurator
                    .from_yaml_file(application.config_path)
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

    def external_config_exists?
      application.config_path && File.exist?(application.config_path)
    end
  end
end
