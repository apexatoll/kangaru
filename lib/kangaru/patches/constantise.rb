module Kangaru
  module Patches
    module Constantise
      refine String do
        def constantise
          Inflectors::Constantiser.new(self).constantise
        end
      end
    end
  end
end
