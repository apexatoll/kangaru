module Kangaru
  class Renderer
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def render(binding)
      return unless path.exist?

      ERB.new(path.read, trim_mode: "-").run(binding)
    end
  end
end
