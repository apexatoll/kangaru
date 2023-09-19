RSpec.describe Kangaru::Inflectors::Constantiser do
  describe ".constantise" do
    subject(:constant) { described_class.constantise(string) }

    let(:string) { "foo/bar/baz" }

    let(:class_value)    { Class.new }
    let(:constant_value) { "Hello world" }

    shared_context :defined_as_class do
      before { stub_const "Foo::Bar::Baz", class_value }
    end

    shared_context :defined_as_constant do
      before { stub_const "Foo::Bar::BAZ", constant_value }
    end

    context "when string is not defined as class or constant in Object" do
      it "returns nil" do
        expect(constant).to be_nil
      end
    end

    context "when string is defined as a constant in Object" do
      include_context :defined_as_constant

      it "returns the constant value" do
        expect(constant).to eq(constant_value)
      end
    end

    context "when string is defined as a class in Object" do
      include_context :defined_as_class

      it "returns the class value" do
        expect(constant).to eq(class_value)
      end
    end

    context "when string is defined as a class and a constant in Object" do
      include_context :defined_as_class
      include_context :defined_as_constant

      it "returns the class value" do
        expect(constant).to eq(class_value)
      end
    end
  end
end
