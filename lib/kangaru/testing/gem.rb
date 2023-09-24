module Kangaru
  module Testing
    class Gem
      include GemPaths

      DEFAULT_NAME = "some_gem".freeze

      attr_reader :dir, :name

      def initialize(dir:, name: DEFAULT_NAME)
        @dir  = dir
        @name = name
      end

      def create!
        `bundle gem #{path}`
      end
    end
  end
end
