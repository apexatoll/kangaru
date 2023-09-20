module Kangaru
  class Application
    using Patches::Inflections

    attr_reader :root_file, :root_dir, :namespace

    def initialize(root_file:, namespace:)
      @root_file = root_file
      @root_dir  = File.dirname(root_file)
      @namespace = namespace
    end

    def app_dir
      @app_dir ||= File.join(root_dir, namespace.to_s.to_snakecase)
    end

    def setup
      autoloader.setup
    end

    private

    def autoloader
      @autoloader ||= Zeitwerk::Loader.new.tap do |loader|
        loader.inflector = Zeitwerk::GemInflector.new(root_file)
        loader.push_dir(app_dir)
      end
    end
  end
end
