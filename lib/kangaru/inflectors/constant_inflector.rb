module Kangaru
  module Inflectors
    class ConstantInflector < ClassInflector
      LAST_WORD = /(::)?(?!.*::)(.*)$/

      def inflect
        super.gsub(LAST_WORD) do |last_word|
          ScreamingSnakecaseInflector.inflect(last_word)
        end
      end
    end
  end
end
