module Kangaru
  module Testing
    class Gem
      DEFAULT_NAME = "some_gem".freeze

      attr_reader :dir, :name

      def initialize(dir:, name: DEFAULT_NAME)
        @dir  = dir
        @name = name
      end

      def create!
        `bundle gem #{gem_path}`
      end

      private

      def gem_path
        @gem_path ||= File.join(dir, name)
      end
    end
  end
end
