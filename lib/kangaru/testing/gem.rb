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
        @lib_path ||= path.join("lib")
      end

      def main_file
        @main_file ||= lib_path.join("#{name}.rb")
      end

      def gem_file(file)
        lib_path.join(name, "#{file}.rb")
      end

      def gem_dir(dir)
        lib_path.join(name, dir)
      end

      def view_path(controller:, action:)
        gem_dir(VIEWS_DIR).join(controller, "#{action}.erb")
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
