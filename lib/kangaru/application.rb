module Kangaru
  class Application
    attr_reader :root_file, :root_dir, :namespace

    def initialize(root_file:, namespace:)
      @root_file = root_file
      @root_dir  = File.dirname(root_file)
      @namespace = namespace
    end
  end
end
