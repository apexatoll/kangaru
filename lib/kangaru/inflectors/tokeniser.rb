module Kangaru
  module Inflectors
    class Tokeniser
      GROUP_DELIMITER = %r{/|::}
      TOKEN_DELIMITER = /[_-]+|(?=[A-Z][a-z])/

      attr_reader :string

      def initialize(string)
        @string = string
      end

      def split
        string.split(GROUP_DELIMITER).map do |group|
          group.split(TOKEN_DELIMITER)
        end
      end
    end
  end
end
