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
      it "returns :runtime" do
        expect(described_class.env).to eq(:runtime)
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
