module Kangaru
  module Testing
    class Gem
      class GemNotCreatedError < StandardError; end

      DEFAULT_NAME = "some_gem".freeze
      VIEWS_DIR    = "views".freeze

      attr_reader :dir, :name

      def initialize(dir:, name: DEFAULT_NAME)
        @dir  = Pathname.new(dir)
        @name = name
      end

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

      def created?
        @created == true
      end

      def create!
        `bundle gem #{path}`

        @created = true
      end

      def load!
        raise GemNotCreatedError, "gem must be created first" unless created?

        require main_file.to_s
      end
    end
  end
end
