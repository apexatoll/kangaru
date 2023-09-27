module Kangaru
  class Application
    using Patches::Inflections

    include ApplicationPaths

    attr_reader :name, :dir, :namespace

    def initialize(name:, dir:, namespace:)
      @name = name
      @dir = dir
      @namespace = namespace
    end

    def config
      @config ||= Config.new
    end

    def setup
      autoloader.setup
    end

    def run!(argv)
      command = Command.parse(argv)

      Router.new(command, namespace:).resolve
    end

    def self.from_callsite(callsite, namespace:)
      name = File.basename(callsite).delete_suffix(".rb")
      dir  = File.dirname(callsite).delete_suffix("/#{name}/lib")

      new(name:, dir:, namespace:)
    end

    private

    def autoloader
      @autoloader ||= Zeitwerk::Loader.new.tap do |loader|
        loader.inflector = Zeitwerk::GemInflector.new(main_file.to_s)
        loader.push_dir(lib_path.to_s)
      end
    end
  end
end
