RSpec.describe Kangaru::Initialiser do
  subject(:namespace) { Namespace }

  before { stub_const "Namespace", Module.new }

  describe ".extended" do
    subject(:extended) { namespace.extend(described_class) }

    before do
      allow(Kangaru::Application).to receive(:new).and_return(application)
    end

    after do
      Kangaru.remove_instance_variable(:@application)
    end

    let(:application) { instance_spy(Kangaru::Application) }

    it "instantiates an application with the inferred filename and namespace" do
      extended

      expect(Kangaru::Application)
        .to have_received(:new)
        .with(root_file: __FILE__, namespace: Namespace)
        .once
    end

    it "sets the Kangaru application attribute to the created application" do
      expect { extended }.to change { Kangaru.application }.to(application)
    end

    it "sets up the application" do
      extended
      expect(application).to have_received(:setup).once
    end
  end
end
