module Kangaru
  module Patches
    module Inflections
      refine String do
        def to_class_name(suffix: nil)
          class_name = Inflectors::ClassInflector.inflect(self)

          [class_name, suffix.to_s.capitalize].compact.join
        end

        def to_constant_name
          Inflectors::ConstantInflector.inflect(self)
        end

        def to_snakecase
          Inflectors::SnakecaseInflector.inflect(self)
        end

        def to_humanised
          Inflectors::HumanInflector.inflect(self)
        end
      end
    end
  end
end
