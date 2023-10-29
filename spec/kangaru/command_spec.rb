RSpec.describe Kangaru::Command do
  subject(:command) { described_class.new(**attributes) }

  let(:attributes) { { path:, action:, id:, arguments: } }

  let(:path)      { nil }
  let(:action)    { nil }
  let(:id)        { nil }
  let(:arguments) { nil }

  describe "#path" do
    context "when no path is set at initialisation" do
      let(:path) { nil }

      it "returns the default path" do
        expect(command.path).to eq(described_class::DEFAULT_PATH)
      end
    end

    context "when path is set at initialisation" do
      let(:path) { "foo/bar" }

      it "returns the path" do
        expect(command.path).to eq(path)
      end
    end
  end

  describe "#controller_name" do
    subject(:controller_name) { command.controller_name }

    context "when path is not set" do
      let(:path) { nil }

      it "returns the default controller name" do
        expect(controller_name).to eq("DefaultController")
      end
    end

    context "when flat path is set" do
      let(:path) { "foobar" }

      it "returns the expected controller name" do
        expect(controller_name).to eq("FoobarController")
      end
    end

    context "when nested path is set" do
      let(:path) { "foo/bar/baz" }

      it "returns the expected controller name" do
        expect(controller_name).to eq("Foo::Bar::BazController")
      end
    end
  end

  describe "#action" do
    context "when action is not set" do
      let(:action) { nil }

      it "returns the default action" do
        expect(command.action).to eq(described_class::DEFAULT_ACTION)
      end
    end

    context "when action is set" do
      let(:action) { :some_action }

      it "returns the specified action" do
        expect(command.action).to eq(action)
      end
    end
  end
end
