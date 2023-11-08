module Kangaru
  module Initialisers
    module RSpec
      module RequestHelper
        attr_reader :request

        def stub_output(&block)
          stdout  = $stdout
          stderr  = $stderr
          $stdout = File.open(File::NULL, "w")
          $stderr = File.open(File::NULL, "w")

          block.call

          $stdout = stdout
          $stderr = stderr
        end

        def resolve(path, params:)
          @request = Kangaru::Request.new(path:, params:)

          Kangaru.application.router.resolve(request)
        end

        private

        def view_path(name)
          Kangaru.application!.view_path(described_class.path, name.to_s)
        end
      end

      if Object.const_defined?(:RSpec)
        ::RSpec.configure do |config|
          file_path = %r{spec/.*/controllers/}

          config.define_derived_metadata(file_path:) do |metadata|
            metadata[:type] = :request
          end

          config.include RequestHelper, type: :request

          config.around(type: :request) do |spec|
            stub_output { spec.run }
          end
        end
      end
    end
  end
end
