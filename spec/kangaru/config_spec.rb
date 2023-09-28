RSpec.describe Kangaru::Config do
  subject(:config) { described_class.new }

  shared_context :no_configurators_defined do
    before do
      allow(Kangaru::Configurators).to receive(:classes).and_return([])
    end
  end

  shared_context :configurator_defined do
    before do
      allow(Kangaru::Configurators)
        .to receive(:classes)
        .and_return([configurator_class])

      allow(configurator_class)
        .to receive(:new)
        .and_return(configurator)
    end

    after { described_class.undef_method(name) }

    let(:configurator_class) do
      class_spy(Kangaru::Configurators::BaseConfigurator, name:)
    end

    let(:configurator) do
      instance_spy(
        Kangaru::Configurators::BaseConfigurator,
        serialise: configurator_hash
      )
    end

    let(:name) { :foobar }

    let(:configurator_hash) { { hello: "world" } }
  end

  describe "#initialize" do
    context "when no configurators defined" do
      include_context :no_configurators_defined

      it "does not set any accessors" do
        expect { config }.not_to change { described_class.instance_methods }
      end
    end

    context "when configurators defined" do
      include_context :configurator_defined

      it "sets a reader" do
        expect { config }
          .to change { described_class.instance_methods }
          .to(include(name))
      end

      it "instantiates a configurator" do
        config
        expect(configurator_class).to have_received(:new).once
      end

      it "sets the configurators instance variable" do
        expect(config.configurators).to eq(foobar: configurator)
      end
    end
  end

  describe "#serialise" do
    subject(:hash) { config.serialise }

    context "when no configurators defined" do
      include_context :no_configurators_defined

      it "returns an empty hash" do
        expect(hash).to be_empty
      end
    end

    context "when configurators set" do
      include_context :configurator_defined

      it "returns the expected hash" do
        expect(hash).to eq(foobar: { hello: "world" })
      end
    end
  end
end
