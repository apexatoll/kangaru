# Builds Pathname objects for files inside a Ruby gem application. Note that
# this assumes a conventional Ruby gem file structure.
#
# For example:
#   + some_gem/          (gem_dir)
#   | + lib/             (lib_dir)
#   | |-- some_gem.rb    (source)
#   | | + some_gem/      (app_dir)
#   | | |-- some_file.rb (app_path)
#
module Kangaru
  class PathBuilder
    attr_reader :source

    def initialize(source:)
      @source = Pathname.new(source)
    end

    # The directory that contains the gem.
    def dir
      @dir ||= gem_path.dirname
    end

    # Infers the gem name from the source filename.
    def name
      @name ||= source.basename(".rb").to_s
    end

    # Paths inside the root directory of the gem.
    def gem_path(*, ext: nil)
      build_path(*, dir: gem_dir, ext:)
    end

    # Paths inside the lib path of the gem. Conventionally contains two files:
    # 1. gem_name.rb   (source_file)
    # 2. gem_name/*.rb (app_path)
    def lib_path(*, ext: :rb)
      build_path(*, dir: lib_dir, ext:)
    end

    # The gem application directory (gem/lib/gem_name).
    def app_path(*, ext: :rb)
      build_path(*, dir: app_dir, ext:)
    end

    private

    def gem_dir
      @gem_dir ||= lib_dir.dirname
    end

    def lib_dir
      @lib_dir ||= source.dirname
    end

    def app_dir
      @app_dir ||= lib_dir.join(name)
    end

    def build_path(*fragments, dir:, ext:)
      return dir if fragments.empty?

      ext  = ".#{ext}" if ext
      file = "#{fragments.pop}#{ext}"

      dir.join(*fragments, file)
    end
  end
end