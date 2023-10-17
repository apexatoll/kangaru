module Kangaru
  module Patches
    module Symboliser
      refine Hash do
        def symbolise
          to_h do |key, value|
            value = case value
                    when Array, Hash then value.symbolise
                    else value
                    end

            [key.to_sym, value]
          end
        end
      end

      refine Array do
        def symbolise
          map do |value|
            case value
            when Array, Hash then value.symbolise
            else value
            end
          end
        end
      end
    end
  end
end
