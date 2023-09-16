module Kangaru
  module Inflectors
    class ScreamingSnakecaseInflector < SnakecaseInflector
      join_groups_with "::"

      def inflect
        super.upcase
      end
    end
  end
end
