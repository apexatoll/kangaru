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

  describe "#import!" do
    subject(:import!) { config.import!(path) }

    let(:path) { "/some/path/config.yml" }

    let(:example_configurator) do
      Class.new(Kangaru::Configurator) { attr_accessor :attribute }
    end

    let(:another_configurator) do
      Class.new(Kangaru::Configurator) { attr_accessor :attribute }
    end

    let(:contents) { nil }

    before do
      stub_configurator_class(:ExampleConfigurator, example_configurator)
      stub_configurator_class(:AnotherConfigurator, another_configurator)

      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(path).and_return(exists?)
      allow(YAML).to receive(:load_file).with(path).and_return(contents)
    end

    shared_examples :does_not_read_config do
      it "does not read the config file" do
        import!
        expect(YAML).not_to have_received(:load_file)
      end
    end

    shared_examples :reads_config do
      it "reads the config file" do
        import!
        expect(YAML).to have_received(:load_file).with(path).once
      end
    end

    shared_examples :does_not_import_config do
      it "does not raise any errors" do
        expect { import! }.not_to raise_error
      end

      it "does not change the config state" do
        expect { import! }.not_to change { config.serialise }
      end
    end

    shared_examples :imports_config do |**settings|
      it "does not raise any errors" do
        expect { import! }.not_to raise_error
      end

      it "imports the config" do
        expect { import! }.to change { config.serialise }.to(include(settings))
      end
    end

    context "and file does not exist" do
      let(:exists?) { false }

      include_examples :does_not_read_config
      include_examples :does_not_import_config
    end

    context "and file exists" do
      let(:exists?) { true }

      context "and yaml contains 0 keys" do
        let(:contents) { nil }

        include_examples :reads_config
        include_examples :does_not_import_config
      end

      context "and yaml contains 1 key" do
        let(:contents) { { key => settings } }

        context "and key is not a valid configurator name" do
          let(:key)      { "invalid" }
          let(:settings) { { "attribute" => "value" } }

          include_examples :reads_config
          include_examples :does_not_import_config
        end

        context "and key is a valid configurator name" do
          let(:key)      { "example" }
          let(:settings) { { setting_key => "value" } }

          context "and setting key is not a valid configurator attribute" do
            let(:setting_key) { "invalid_attribute" }

            include_examples :reads_config
            include_examples :does_not_import_config
          end

          context "and setting key is a valid configurator attribute" do
            let(:setting_key) { "attribute" }

            include_examples :reads_config
            include_examples :imports_config, example: { attribute: "value" }
          end
        end
      end

      context "and yaml contains 2 keys" do
        let(:contents) do
          { key_one => settings, key_two => settings }
        end

        let(:settings) { { "attribute" => "value" } }

        context "and neither key is a valid configurator name" do
          let(:key_one) { "invalid" }
          let(:key_two) { "also_invalid" }

          include_examples :reads_config
          include_examples :does_not_import_config
        end

        context "and one key is a valid configurator name" do
          let(:key_one) { "invalid" }
          let(:key_two) { "example" }

          include_examples :reads_config
          include_examples :imports_config, example: { attribute: "value" }
        end

        context "and both keys are valid configurator names" do
          let(:key_one) { "example" }
          let(:key_two) { "another" }

          include_examples :reads_config
          include_examples :imports_config, example: { attribute: "value" },
                                            another: { attribute: "value" }
        end
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

  describe "#[]" do
    subject(:configurator) { config[configurator_key] }

    include_context :stub_configurator_classes, with: %i[FoobarConfigurator]

    let(:foobar_configurator) do
      instance_double(Kangaru::Configurators::FoobarConfigurator)
    end

    before do
      allow(Kangaru::Configurators::FoobarConfigurator)
        .to receive(:new)
        .and_return(foobar_configurator)
    end

    context "when configurator with given key does not exist" do
      let(:configurator_key) { :invalid }

      it "does not raise any errors" do
        expect { configurator }.not_to raise_error
      end

      it "returns nil" do
        expect(configurator).to be_nil
      end
    end

    context "when configurator with given key exists" do
      let(:configurator_key) { :foobar }

      it "does not raise any errors" do
        expect { configurator }.not_to raise_error
      end

      it "returns the configurator instance" do
        expect(configurator).to eq(foobar_configurator)
      end
    end
  end
end
