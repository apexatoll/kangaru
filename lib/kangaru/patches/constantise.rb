module Kangaru
  module Patches
    module Constantise
      refine String do
        def constantise
          Inflectors::Constantiser.constantise(self)
        end
      end
    end
  end
end
