module Kangaru
  module Inflectors
    class HumanInflector < Inflector
      transform_tokens_with :downcase

      join_tokens_with " "

      join_groups_with " "

      post_process_with do |output|
        output.strip.capitalize
      end
    end
  end
end
