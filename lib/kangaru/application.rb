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

    # If called with no env, the config will be applied regardless of current
    # env. If multiple configure calls matching the current env are made, the
    # most recent calls will overwrite older changes.
    def configure(env = nil, &block)
      block.call(config) if current_env?(env)
    end

    def apply_config!
      config.import_external_config!

      @database = setup_database!
    end

    def run!(argv)
      command = Command.parse(argv)

      Router.new(command, namespace:).resolve
    end

    def_delegators :paths, :view_path

    private

    # Returns true if nil as this is represents all envs.
    def current_env?(env)
      return true if env.nil?

      Kangaru.env?(env)
    end

    def autoloader
      @autoloader ||= Zeitwerk::Loader.new.tap do |loader|
        loader.inflector = Zeitwerk::GemInflector.new(paths.source.to_s)
        loader.collapse(paths.collapsed_dirs)
        loader.push_dir(paths.lib_path.to_s)
      end
    end

    def setup_database!
      return unless config.database.adaptor

      Database.new(**config.database.serialise).tap do |database|
        database.setup!
        database.migrate!
      end
    end
  end
end
