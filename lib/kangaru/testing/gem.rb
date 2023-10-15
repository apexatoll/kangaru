module Kangaru
  module Testing
    class Gem
      include ApplicationPaths

      class GemNotCreatedError < StandardError; end

      DEFAULT_NAME = "some_gem".freeze

      attr_reader :dir, :name

      def initialize(dir:, name: DEFAULT_NAME)
        @dir  = Pathname.new(dir)
        @name = name
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
