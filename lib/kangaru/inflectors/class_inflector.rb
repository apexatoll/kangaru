module Kangaru
  module Inflectors
    class ClassInflector < Inflector
      filter_input_with(/\.[a-z]+$/)

      transform_tokens_with :capitalize

      join_tokens_with ""

      join_groups_with "::"
    end
  end
end
