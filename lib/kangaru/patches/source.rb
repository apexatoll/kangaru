module Kangaru
  module Patches
    module Source
      refine Module do
        def source
          Object.const_source_location(name || raise)&.first || raise
        end
      end
    end
  end
end
