module Kangaru
  module Inflectors
    class SnakecaseInflector < Inflector
      transform_tokens_with :downcase

      join_tokens_with "_"

      join_groups_with "/"
    end
  end
end
