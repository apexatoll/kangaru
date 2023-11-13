module Kangaru
  class Application
    extend Forwardable

    class InvalidConfigError < StandardError; end

    attr_reader :paths, :namespace, :database

    attr_accessor :config_path

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

    def configure(&block)
      block.call(config)
    end

    def configured?
      @configured == true
    end

    def apply_config!
      raise "config already applied" if configured?

      config.import!(config_path) unless config_path.nil?

      validate_config!

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

    def autoloader
      @autoloader ||= Zeitwerk::Loader.new.tap do |loader|
        loader.inflector = Zeitwerk::GemInflector.new(paths.source.to_s)
        loader.collapse(paths.collapsed_dirs)
        loader.push_dir(paths.lib_path.to_s)
      end
    end

    def validate_config!
      return if config.valid?

      message = config.errors.map(&:full_message).join(", ")

      raise InvalidConfigError, message
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
