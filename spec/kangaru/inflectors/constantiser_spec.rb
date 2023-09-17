RSpec.describe Kangaru::Inflectors::Constantiser do
  subject(:constantiser) { described_class.new(string) }

  describe "#constantise" do
    subject(:constant) { constantiser.constantise }

    let(:string) { "foo/bar/baz" }

    context "when string is not inflectable" do
      it "returns nil" do
        expect(constant).to be_nil
      end
    end

    context "when string can be inflected to an existing constant" do
      before { stub_const "Foo::Bar::BAZ", constant_value }

      let(:constant_value) { "Hello world" }

      it "returns the constant value" do
        expect(constant).to eq(constant_value)
      end
    end

    context "when string can be inflected to an existing class" do
      before { stub_const "Foo::Bar::Baz", class_value }

      let(:class_value) { Class.new }

      it "returns the class value" do
        expect(constant).to eq(class_value)
      end
    end

    context "when string can be inflected to either a class or a constant" do
      before do
        stub_const "Foo::Bar::Baz", class_value
        stub_const "Foo::Bar::BAZ", constant_value
      end

      let(:class_value)    { Class.new }
      let(:constant_value) { "Hello world" }

      it "returns the class value" do
        expect(constant).to eq(class_value)
      end
    end
  end
end
