module Kangaru
  module Testing
    class Gem
      DEFAULT_NAME = "some_gem".freeze

      attr_reader :dir, :name

      def initialize(dir:, name: DEFAULT_NAME)
        @dir  = dir
        @name = name
      end
    end
  end
end
