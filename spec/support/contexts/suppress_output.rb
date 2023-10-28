RSpec.configure do |config|
  config.before(suppress_output: true) do
    allow($stdout).to receive(:write)
    allow($stderr).to receive(:write)
  end
end
