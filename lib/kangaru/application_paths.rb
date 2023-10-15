module Kangaru
  module ApplicationPaths
    VIEWS_DIR = "views".freeze

    def path
      @path ||= dir.join(name)
    end

    def lib_path
      @lib_path ||= Pathname.new(File.join(path.to_s, "lib"))
    end

    def main_file
      @main_file ||= Pathname.new(File.join(lib_path.to_s, "#{name}.rb"))
    end

    def gem_file(file)
      Pathname.new(File.join(lib_path.to_s, name, "#{file}.rb"))
    end

    def gem_dir(dir)
      Pathname.new(File.join(lib_path.to_s, name, dir))
    end

    def view_path(controller:, action:)
      Pathname.new(
        File.join(gem_dir(VIEWS_DIR).to_s, controller, "#{action}.erb")
      )
    end
  end
end
