module Kangaru
  class Application
    using Patches::Inflections

    attr_reader :root_file, :root_dir, :namespace

    def initialize(root_file:, namespace:)
      @root_file = Pathname.new(root_file)
      @root_dir  = @root_file.dirname
      @namespace = namespace
    end

    def setup
      autoloader.setup
    end

    def run!(argv)
      command = Command.parse(argv)

      Router.new(command, namespace:).resolve
    end

    private

    def autoloader
      @autoloader ||= Zeitwerk::Loader.new.tap do |loader|
        loader.inflector = Zeitwerk::GemInflector.new(root_file.to_s)
        loader.push_dir(root_dir.to_s)
      end
    end
  end
end
