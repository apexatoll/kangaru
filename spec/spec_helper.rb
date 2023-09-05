require "kangaru"

RSpec.configure do |config|
  Kernel.srand(config.seed)

  config.default_formatter = :doc if config.files_to_run.one?

  config.disable_monkey_patching!

  config.mock_with(:rspec) { |mocks| mocks.verify_partial_doubles = true }

  config.order = :random
end
