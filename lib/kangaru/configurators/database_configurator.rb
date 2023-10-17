module Kangaru
  module Configurators
    class DatabaseConfigurator < Configurator
      attr_accessor :adaptor, :path, :migration_path
    end
  end
end
