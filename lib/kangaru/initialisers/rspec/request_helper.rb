module Kangaru
  module Initialisers
    module RSpec
      module RequestHelper
      end

      if Object.const_defined?(:RSpec)
        ::RSpec.configure do |config|
          file_path = %r{spec/.*/controllers/}

          config.define_derived_metadata(file_path:) do |metadata|
            metadata[:type] = :request
          end

          config.include RequestHelper, type: :request
        end
      end
    end
  end
end
