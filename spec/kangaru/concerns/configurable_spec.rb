RSpec.describe Kangaru::Concerns::Configurable do
  subject(:configurable) { configurable_class.new }

  let(:configurable_class) do
    Class.new { include Kangaru::Concerns::Configurable }
  end

  let(:name) { "Kangaru::SomeClass" }

  before { allow(configurable_class).to receive(:name).and_return(name) }

  describe ".configurator_name" do
    subject(:configurator_name) { configurable_class.configurator_name }

    shared_examples :returns_configurator_name do
      context "when class name is not set" do
        let(:name) { nil }

        it "raises an error" do
          expect { configurator_name }.to raise_error("class name not set")
        end
      end

      context "when class name is not nested" do
        let(:name) { "#{base}::SomeClass" }

        it "does not raise any errors" do
          expect { configurator_name }.not_to raise_error
        end

        it "returns a string" do
          expect(configurator_name).to be_a(String)
        end

        it "returns the expected configurator class name" do
          expect(configurator_name).to eq(
            "#{base}::Configurators::SomeClassConfigurator"
          )
        end
      end

      context "when class name is nested" do
        let(:name) { "#{base}::SomeNamespace::SomeClass" }

        it "does not raise any errors" do
          expect { configurator_name }.not_to raise_error
        end

        it "returns a string" do
          expect(configurator_name).to be_a(String)
        end

        it "returns the expected configurator class name" do
          expect(configurator_name).to eq(
            "#{base}::Configurators::SomeNamespace::SomeClassConfigurator"
          )
        end
      end
    end

    describe "within Kangaru" do
      let(:base) { "Kangaru" }

      include_examples :returns_configurator_name
    end

    describe "within target gem" do
      let(:base) { "SomeGem" }

      include_examples :returns_configurator_name
    end
  end

  describe "#config", :stub_application do
    subject(:config) { configurable.config }

    let(:application_config) { instance_spy(Kangaru::Config) }

    before do
      allow(application)
        .to receive(:config)
        .and_return(application_config)

      allow(application_config)
        .to receive(:for)
        .with(configurable.class.configurator_name)
        .and_return(configurator)
    end

    context "when inferred configurator has not been set by application" do
      let(:configurator) { nil }

      it "raises an error" do
        expect { config }.to raise_error(
          "inferred configurator not set by application"
        )
      end
    end

    context "when inferred configurator has been set by application" do
      let(:configurator) { instance_double(Kangaru::Configurator) }

      it "does not raise any errors" do
        expect { config }.not_to raise_error
      end

      it "queries the application config for the inferred configurator" do
        config

        expect(application_config)
          .to have_received(:for)
          .with(configurable.class.configurator_name)
          .once
      end

      it "returns the configurator" do
        expect(config).to eq(configurator)
      end
    end
  end
end
