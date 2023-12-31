RSpec.describe Kangaru::Configurable do
  subject(:configurable) { configurable_class.new }

  let(:configurable_class) do
    Class.new { include Kangaru::Configurable }
  end

  let(:name) { "Kangaru::SomeNamespace::Example" }

  before { allow(configurable_class).to receive(:name).and_return(name) }

  describe ".configurator_key" do
    subject(:configurator_key) { configurable_class.configurator_key }

    shared_examples :returns_configurator_key do
      context "when class name is not set" do
        let(:name) { nil }

        it "raises an error" do
          expect { configurator_key }.to raise_error("class name not set")
        end
      end

      context "when class name is set" do
        let(:name) { "#{base}::SomeClass" }

        it "does not raise any errors" do
          expect { configurator_key }.not_to raise_error
        end

        it "returns the expected configurator class name" do
          expect(configurator_key).to eq(:some_class)
        end
      end
    end

    describe "within Kangaru" do
      let(:base) { "Kangaru" }

      include_examples :returns_configurator_key
    end

    describe "within target gem" do
      let(:base) { "SomeGem" }

      include_examples :returns_configurator_key
    end
  end

  describe "#config", :stub_application do
    subject(:config) { configurable.config }

    let(:application_config) { instance_spy(Kangaru::Config) }

    let(:configurators) { { example: example_configurator }.compact }

    before do
      allow(application)
        .to receive(:config)
        .and_return(application_config)

      allow(application_config).to receive(:[]) { |key| configurators[key] }
    end

    context "when inferred configurator has not been set by application" do
      let(:example_configurator) { nil }

      it "raises an error" do
        expect { config }.to raise_error(
          "inferred configurator not set by application"
        )
      end
    end

    context "when inferred configurator has been set by application" do
      let(:example_configurator) { instance_double(Kangaru::Configurator) }

      it "does not raise any errors" do
        expect { config }.not_to raise_error
      end

      it "queries the application config for the inferred configurator" do
        config
        expect(application_config).to have_received(:[]).with(:example).once
      end

      it "returns the configurator" do
        expect(config).to eq(example_configurator)
      end
    end
  end
end
