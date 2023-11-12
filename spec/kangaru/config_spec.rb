RSpec.describe Kangaru::Config do
  subject(:config) { described_class.new }

  def stub_configurator_class(name, configurator_class)
    class_name = "Kangaru::Configurators::#{name}"

    allow(configurator_class).to receive(:name).and_return(class_name)

    stub_const class_name, configurator_class
  end

  shared_context :stub_configurator_classes do |options|
    let(:classes) { options[:with] }

    before do
      allow(Kangaru::Configurators).to receive(:constants).and_return(classes)

      classes.each do |name|
        stub_configurator_class(name, Class.new(Kangaru::Configurator))
      end
    end
  end

  describe "#initialise" do
    context "when no configurator classes are defined" do
      include_context :stub_configurator_classes, with: []

      it "does not set any configurators" do
        expect(config.configurators).to be_empty
      end
    end

    context "when configurator classes are defined" do
      include_context :stub_configurator_classes,
                      with: %i[FooConfigurator BarConfigurator]

      let(:foo) { instance_double(Kangaru::Configurators::FooConfigurator) }
      let(:bar) { instance_double(Kangaru::Configurators::BarConfigurator) }

      before do
        allow(Kangaru::Configurators::FooConfigurator)
          .to receive(:new)
          .and_return(foo)

        allow(Kangaru::Configurators::BarConfigurator)
          .to receive(:new)
          .and_return(bar)
      end

      it "sets the configurators" do
        expect(config).to have_attributes(foo:, bar:)
      end
    end
  end

  describe "#serialise" do
    subject(:hash) { config.serialise }

    context "when no configurator classes are defined" do
      include_context :stub_configurator_classes, with: []

      it "returns an empty hash" do
        expect(hash).to be_empty
      end
    end

    context "when configurator classes are defined" do
      include_context :stub_configurator_classes,
                      with: %i[FooConfigurator BarConfigurator]

      let(:foo) do
        instance_double(
          Kangaru::Configurators::FooConfigurator,
          serialise: foo_hash
        )
      end

      let(:bar) do
        instance_double(
          Kangaru::Configurators::BarConfigurator,
          serialise: bar_hash
        )
      end

      let(:foo_hash) { { foo: "foo" } }
      let(:bar_hash) { { bar: "bar" } }

      before do
        allow(Kangaru::Configurators::FooConfigurator)
          .to receive(:new)
          .and_return(foo)

        allow(Kangaru::Configurators::BarConfigurator)
          .to receive(:new)
          .and_return(bar)
      end

      it "returns the expected serialised hash" do
        expect(hash).to eq(foo: { foo: "foo" }, bar: { bar: "bar" })
      end
    end
  end

  describe "#import!" do
    subject(:import!) { config.import! }

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
        expect(import!).to be_nil
      end

      it "does not raise any errors" do
        expect { import! }.not_to raise_error
      end

      it "does not update the external configuration" do
        expect { import! }.not_to change { config.external }
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
        expect { import! }.not_to raise_error
      end

      it "reads the yaml file and builds an external configurator" do
        import!

        expect(Kangaru::Configurators::ExternalConfigurator)
          .to have_received(:from_yaml_file)
          .with(config_path).once
      end

      it "updates the external config instance to the imported instance" do
        expect { import! }
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

  describe "#for" do
    subject(:configurator) { config.for(configurator_name) }

    let(:configurator_name) { "Kangaru::Configurators::FoobarConfigurator" }

    context "when configurator with given name is not set" do
      include_context :stub_configurator_classes, with: []

      it "does not raise any errors" do
        expect { configurator }.not_to raise_error
      end

      it "returns nil" do
        expect(configurator).to be_nil
      end
    end

    context "when configurator with given name is set" do
      include_context :stub_configurator_classes, with: [:FoobarConfigurator]

      let(:foobar_configurator) do
        instance_double(
          Kangaru::Configurators::FoobarConfigurator,
          class: Kangaru::Configurators::FoobarConfigurator
        )
      end

      before do
        allow(Kangaru::Configurators::FoobarConfigurator)
          .to receive(:new)
          .and_return(foobar_configurator)
      end

      it "does not raise any errors" do
        expect { configurator }.not_to raise_error
      end

      it "returns the expected configurator" do
        expect(configurator).to eq(foobar_configurator)
      end
    end
  end
end
