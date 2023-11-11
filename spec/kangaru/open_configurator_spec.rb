RSpec.describe Kangaru::OpenConfigurator do
  subject(:open_configurator) { described_class.new(**attributes) }

  let(:attributes) { { foo: "foo", bar: "bar", baz: "baz" } }

  describe "#initialize" do
    it "sets attributes for all given input attributes" do
      expect(open_configurator).to have_attributes(**attributes)
    end
  end

  describe ".from_yaml_file" do
    subject(:open_configurator) { described_class.from_yaml_file(path) }

    let(:path) { "/some/file.yaml" }

    let(:string_hash) { { "foo" => "foo", "bar" => "bar", "baz" => "baz" } }

    let(:expected_attributes) { { foo: "foo", bar: "bar", baz: "baz" } }

    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(path).and_return(exists?)
      allow(YAML).to receive(:load_file).with(path).and_return(string_hash)
    end

    context "when specified file does not exist" do
      let(:exists?) { false }

      it "raises an error" do
        expect { open_configurator }.to raise_error("path does not exist")
      end
    end

    context "when specified file exists" do
      let(:exists?) { true }

      context "and file is empty" do
        let(:string_hash) { nil }

        it "does not raise any errors" do
          expect { open_configurator }.not_to raise_error
        end

        it "returns an OpenConfigurator" do
          expect(open_configurator).to be_a(described_class)
        end
      end

      context "and file is not empty" do
        let(:string_hash) { { "foo" => "foo", "bar" => "bar", "baz" => "baz" } }

        it "does not raise any errors" do
          expect { open_configurator }.not_to raise_error
        end

        it "returns an OpenConfigurator" do
          expect(open_configurator).to be_a(described_class)
        end

        it "parses and sets the attributes" do
          expect(open_configurator).to have_attributes(**expected_attributes)
        end
      end
    end
  end
end
