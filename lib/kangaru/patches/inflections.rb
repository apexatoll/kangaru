module Kangaru
  module Patches
    module Inflections
      refine String do
        def to_class_name
          Inflectors::ClassInflector.inflect(self)
        end

        def to_constant_name
          Inflectors::ConstantInflector.inflect(self)
        end
      end
    end
  end
end
