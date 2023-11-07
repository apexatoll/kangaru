module Kangaru
  module Initialisers
    module RSpec
      if Object.const_defined?(:RSpec)
        ::RSpec.configure do |config|
          Kangaru.env = :test

          config.include KangaruHelper

          config.around do |spec|
            run_in_transaction { spec.run }
          end
        end
      end
    end
  end
end
