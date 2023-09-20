module Kangaru
  module Patches
    module Constantise
      refine String do
        def constantise(root: Object)
          Inflectors::Constantiser.constantise(self, root:)
        end
      end
    end
  end
end
