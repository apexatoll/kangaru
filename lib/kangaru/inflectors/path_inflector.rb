module Kangaru
  module Inflectors
    class PathInflector < Inflector
      filter_input_with(/\.[a-z]+$/)

      transform_tokens_with :downcase

      join_tokens_with "_"

      join_groups_with "/"

      def inflect(with_ext: nil)
        inflection = super()

        return inflection unless with_ext

        "#{inflection}.#{with_ext}"
      end
    end
  end
end
