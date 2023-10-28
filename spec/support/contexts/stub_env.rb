RSpec.configure do |config|
  config.before(stub_env: true) do
    allow(Kangaru).to receive(:env).and_return(current_env)
  end
end
