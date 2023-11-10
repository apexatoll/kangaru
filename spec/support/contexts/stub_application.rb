RSpec.shared_context stub_application: true do
  let(:application) { instance_double(Kangaru::Application, namespace:) }

  let(:namespace) { Application }

  before do
    stub_const "Application", Module.new

    allow(Kangaru).to receive(:application).and_return(application)
  end
end
