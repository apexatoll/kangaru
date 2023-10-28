module Kangaru
  class Component
    using Patches::Inflections
    using Patches::Source

    def render
      Renderer.new(view_file).render(binding)
    end

    private

    def view_file
      dir = File.dirname(self.class.source)
      name = File.basename(self.class.source, ".rb")

      Pathname.new(dir).join("#{name}.erb")
    end
  end
end
