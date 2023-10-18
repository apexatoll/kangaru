# Builds Pathname objects for files inside a Ruby gem application. Note that
# this assumes a conventional Ruby gem file structure.
#
# For example:
#   + some_gem/          (gem_dir)
#   | + lib/             (lib_dir)
#   | |-- some_gem.rb    (source)
#   | | + some_gem/      (app_dir)
#   | | |-- some_file.rb (path)
#
module Kangaru
  class Paths
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
    def path(*, ext: :rb)
      build_path(*, dir: app_dir, ext:)
    end

    def view_path(controller:, action:, ext: :erb)
      build_path(controller, action, dir: views_dir, ext:)
    end

    def collapsed_dirs
      [models_dir, controllers_dir].map(&:to_s)
    end

    private

    MODELS_DIRNAME      = "models".freeze
    VIEWS_DIRNAME       = "views".freeze
    CONTROLLERS_DIRNAME = "controllers".freeze

    def gem_dir
      @gem_dir ||= lib_dir.dirname
    end

    def lib_dir
      @lib_dir ||= source.dirname
    end

    def app_dir
      @app_dir ||= lib_dir.join(name)
    end

    def models_dir
      @models_dir ||= app_dir.join(MODELS_DIRNAME)
    end

    def views_dir
      @views_dir ||= app_dir.join(VIEWS_DIRNAME)
    end

    def controllers_dir
      @controllers_dir ||= app_dir.join(CONTROLLERS_DIRNAME)
    end

    def build_path(*fragments, dir:, ext:)
      return dir if fragments.empty?

      ext  = ".#{ext}" if ext
      file = "#{fragments.pop}#{ext}"

      dir.join(*fragments, file)
    end
  end
end
