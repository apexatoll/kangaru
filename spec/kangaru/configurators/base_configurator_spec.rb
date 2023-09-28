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

  describe "#serialise" do
    subject(:hash) { configurator.serialise }

    context "when no attr_accessors are set" do
      let(:configurator) do
        Class.new(described_class).new
      end

      it "returns an empty hash" do
        expect(hash).to be_empty
      end
    end

    context "when attr_accessors are set" do
      let(:configurator) do
        Class.new(described_class) do
          attr_accessor :foo, :bar, :baz
        end.new
      end

      context "and values are not set" do
        it "returns an empty hash" do
          expect(hash).to be_empty
        end
      end

      context "and values are set" do
        let(:foo) { :foo }
        let(:bar) { true }
        let(:baz) { 3.14 }

        before do
          configurator.foo = foo
          configurator.bar = bar
          configurator.baz = baz
        end

        it "returns the expected hash" do
          expect(hash).to eq(foo:, bar:, baz:)
        end
      end
    end
  end
end
