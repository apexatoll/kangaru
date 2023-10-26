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
