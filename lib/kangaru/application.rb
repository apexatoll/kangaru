module Kangaru
  class Application
    using Patches::Inflections

    include ApplicationPaths

    attr_reader :name, :dir, :namespace, :config, :database

    def initialize(name:, dir:, namespace:)
      @name = name
      @dir = dir
      @namespace = namespace
      @config = Config.new

      autoloader.setup
    end

    def configure(&block)
      block.call(config)

      setup
    end

    def run!(argv)
      command = Command.parse(argv)

      Router.new(command, namespace:).resolve
    end

    def self.from_callsite(source:, namespace:)
      name = File.basename(source).delete_suffix(".rb")
      dir  = File.dirname(source).delete_suffix("/#{name}/lib")

      new(name:, dir:, namespace:)
    end

    private

    def autoloader
      @autoloader ||= Zeitwerk::Loader.new.tap do |loader|
        loader.inflector = Zeitwerk::GemInflector.new(main_file.to_s)
        loader.push_dir(lib_path.to_s)
      end
    end

    def setup
      return if config.database.adaptor.nil?

      @database = Database.new(**config.database.serialise).tap(&:setup!)
    end
  end
end
