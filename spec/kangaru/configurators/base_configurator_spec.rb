RSpec.describe Kangaru::Configurators::BaseConfigurator do
  describe ".name" do
    subject(:name) { configurator_class.name }

    let(:configurator_class) do
      Class.new(described_class) do
        def self.to_s = "FoobarConfigurator"
      end
    end

    it "returns the expected name" do
      expect(name).to eq(:foobar)
    end
  end

  describe ".settings" do
    subject(:settings) { configurator_class.settings }

    context "when no attr_accessors are set" do
      let(:configurator_class) do
        Class.new(described_class)
      end

      it "returns an empty array" do
        expect(settings).to be_empty
      end
    end

    context "when attr_accessors are set" do
      let(:configurator_class) do
        Class.new(described_class) do
          attr_accessor :foo, :bar, :baz
        end
      end

      it "returns the expected settings" do
        expect(settings).to contain_exactly(:foo, :bar, :baz)
      end
    end
  end
end
