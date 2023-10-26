module Kangaru
  module Initialisers
    module RSpec
      if Object.const_defined?(:RSpec)
        ::RSpec.configure do
          Kangaru.env = :test
        end
      end
    end
  end
end
