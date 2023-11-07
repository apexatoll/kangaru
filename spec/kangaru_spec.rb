RSpec.describe Kangaru do
  describe "@loader" do
    subject(:loader) { described_class.instance_variable_get(:@loader) }

    let(:lib_directory) { File.join(File.dirname(__dir__), "lib") }

    it "sets the @loader instance variable" do
      expect(described_class).to be_instance_variable_defined(:@loader)
    end

    it "sets the instance variable to a Zeitwerk loader" do
      expect(loader).to be_a(Zeitwerk::Loader)
    end

    it "autoloads the lib directory" do
      expect(loader.dirs).to include(lib_directory)
    end
  end

  describe "#application" do
    subject(:application) { described_class.application }

    context "when application is not set" do
      it "does not raise any errors" do
        expect { application }.not_to raise_error
      end

      it "returns nil" do
        expect(application).to be_nil
      end
    end

    context "when application is set" do
      around do |spec|
        described_class.instance_variable_set(:@application, instance)
        spec.run
        described_class.remove_instance_variable(:@application)
      end

      let(:instance) { instance_double(Kangaru::Application) }

      it "does not raise any errors" do
        expect { application }.not_to raise_error
      end

      it "returns the application instance" do
        expect(application).to eq(instance)
      end
    end
  end

  describe "#application!" do
    subject(:application!) { described_class.application! }

    context "when application is not set" do
      it "raises an error" do
        expect { application! }.to raise_error("application not set")
      end
    end

    context "when application is set" do
      around do |spec|
        described_class.instance_variable_set(:@application, instance)
        spec.run
        described_class.remove_instance_variable(:@application)
      end

      let(:instance) { instance_double(Kangaru::Application) }

      it "does not raise any errors" do
        expect { application! }.not_to raise_error
      end

      it "returns the application instance" do
        expect(application!).to eq(instance)
      end
    end
  end

  describe ".env=" do
    subject(:set_env) { described_class.env = env }

    def env_ivar = described_class.instance_variable_get(:@env)

    after do
      described_class.remove_instance_variable(:@env) if env_ivar
    end

    context "when env is a symbol" do
      let(:env) { :env }

      it "sets to a symbol" do
        expect { set_env }.to change { env_ivar }.to(env)
      end
    end

    context "when env is a string" do
      let(:env) { "env" }

      it "sets to a symbol" do
        expect { set_env }.to change { env_ivar }.to(env.to_sym)
      end
    end
  end

  describe ".env" do
    subject(:env) { described_class.env }

    def env_ivar = described_class.instance_variable_get(:@env)

    around do |spec|
      described_class.remove_instance_variable(:@env) if env_ivar
      spec.run
      described_class.remove_instance_variable(:@env) if env_ivar
    end

    context "when env is not set" do
      it "returns the default env" do
        expect(described_class.env).to eq(described_class::DEFAULT_ENV)
      end
    end

    context "when env is set" do
      before { described_class.env = env }

      let(:env) { :foobar }

      it "returns the set value" do
        expect(described_class.env).to eq(env)
      end
    end
  end

  describe ".env?" do
    before { described_class.env = :foo }

    context "when value is not current env" do
      let(:value) { :bar }

      it "returns false" do
        expect(described_class).not_to be_env(value)
      end
    end

    context "when value is current env" do
      let(:value) { :foo }

      it "returns true" do
        expect(described_class).to be_env(value)
      end
    end
  end

  describe ".eager_load" do
    subject(:eager_load) { described_class.eager_load(namespace) }

    let(:namespace) { Module.new }

    let(:loader) { described_class.instance_variable_get(:@loader) }

    before { allow(loader).to receive(:eager_load_namespace) }

    it "delegates to the zeitwerk loader" do
      eager_load

      expect(loader)
        .to have_received(:eager_load_namespace)
        .with(namespace)
        .once
    end
  end
end
