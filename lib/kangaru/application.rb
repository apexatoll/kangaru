module Kangaru
  class Application
    extend Forwardable

    attr_reader :paths, :namespace, :database

    def initialize(source:, namespace:)
      @paths = Paths.new(source:)
      @namespace = namespace

      autoloader.setup
    end

    # Lazy-loaded to allow defaults to be set after application is created.
    def config
      @config ||= Config.new
    end

    def router
      @router ||= Router.new(namespace:)
    end

    # If called with no env, the config will be applied regardless of current
    # env. If multiple configure calls matching the current env are made, the
    # most recent calls will overwrite older changes.
    def configure(env = nil, &block)
      block.call(config) if current_env?(env)
    end

    def configured?
      @configured == true
    end

    def apply_config!
      raise "config already applied" if configured?

      config.import!

      @database = setup_database!
      @configured = true
    end

    def run!(*argv)
      request = RequestBuilder.new(argv).build

      router.resolve(request)
    end

    def const_get(const)
      return unless namespace.const_defined?(const)

      namespace.const_get(const)
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
