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

    after { described_class.undef_method(key) }

    let(:configurator_class) do
      class_spy(Kangaru::Configurators::Configurator, key:)
    end

    let(:configurator) do
      instance_spy(
        Kangaru::Configurators::Configurator,
        serialise: configurator_hash
      )
    end

    let(:key) { :foobar }

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
          .to(include(key))
      end

      it "instantiates a configurator" do
        config
        expect(configurator_class).to have_received(:new).once
      end

      it "sets the configurators instance variable" do
        expect(config.configurators).to eq(key => configurator)
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

  describe "#import_external_config!" do
    subject(:import_external_config!) { config.import_external_config! }

    before do
      allow(Kangaru::Configurators::ApplicationConfigurator)
        .to receive(:new)
        .and_return(application)
    end

    let(:application) do
      instance_double(
        Kangaru::Configurators::ApplicationConfigurator,
        config_path:
      )
    end

    shared_examples :does_not_import_external_config do
      it "returns nil" do
        expect(import_external_config!).to be_nil
      end

      it "does not raise any errors" do
        expect { import_external_config! }.not_to raise_error
      end

      it "does not update the external configuration" do
        expect { import_external_config! }.not_to change { config.external }
      end
    end

    shared_examples :imports_external_config do
      before do
        allow(Kangaru::Configurators::ExternalConfigurator)
          .to receive(:from_yaml_file)
          .with(config_path)
          .and_return(external)
      end

      let(:external) do
        instance_double(Kangaru::Configurators::ExternalConfigurator)
      end

      it "does not raise any errors" do
        expect { import_external_config! }.not_to raise_error
      end

      it "reads the yaml file and builds an external configurator" do
        import_external_config!

        expect(Kangaru::Configurators::ExternalConfigurator)
          .to have_received(:from_yaml_file)
          .with(config_path).once
      end

      it "updates the external config instance to the imported instance" do
        expect { import_external_config! }
          .to change { config.external }
          .to(external)
      end
    end

    context "when application config_path is not configured" do
      let(:config_path) { nil }

      include_examples :does_not_import_external_config
    end

    context "when application config_path is configured" do
      let(:config_path) { "/some/path/config.yml" }

      before do
        allow(File).to receive(:exist?).with(config_path).and_return(exists?)
      end

      context "and no file exists at specified path" do
        let(:exists?) { false }

        include_examples :does_not_import_external_config
      end

      context "and file exists at specified path" do
        let(:exists?) { true }

        include_examples :imports_external_config
      end
    end
  end
end
