module Kangaru
  class Application
    extend Forwardable

    attr_reader :paths, :namespace, :config, :database

    def initialize(source:, namespace:)
      @paths = Paths.new(source:)
      @namespace = namespace
      @config = Config.new

      autoloader.setup
    end

    def configure(&block)
      block.call(config)

      apply_config!
    end

    def run!(argv)
      command = Command.parse(argv)

      Router.new(command, namespace:).resolve
    end

    def_delegators :paths, :view_path

    private

    def autoloader
      @autoloader ||= Zeitwerk::Loader.new.tap do |loader|
        loader.inflector = Zeitwerk::GemInflector.new(paths.source.to_s)
        loader.push_dir(paths.lib_path.to_s)
      end
    end

    def apply_config!
      if config.database.adaptor
        @database = Database.new(**config.database.serialise).tap(&:setup!)
      end

      config.import_external_config!
    end
  end
end
