RSpec.describe Kangaru::Command do
  subject(:command) { described_class.new(**attributes) }

  let(:attributes) { { controller:, action:, arguments: } }

  let(:controller) { "FoobarController" }
  let(:action)     { :do_something }
  let(:arguments)  { { force: true } }

  describe "#initialize" do
    it "sets the attributes" do
      expect(command).to have_attributes(**attributes)
    end
  end

  describe ".from_argv" do
    subject(:command) { described_class.from_argv(tokens) }

    let(:tokens) { %w[foo bar baz] }

    before do
      allow(Kangaru::InputParsers::ControllerParser)
        .to receive(:parse)
        .with(tokens)
        .and_return(controller)

      allow(Kangaru::InputParsers::ActionParser)
        .to receive(:parse)
        .with(tokens)
        .and_return(action)

      allow(Kangaru::InputParsers::ArgumentParser)
        .to receive(:parse)
        .with(tokens)
        .and_return(arguments)
    end

    it "returns an command object" do
      expect(command).to be_a(described_class)
    end

    it "sets the expected attributes" do
      expect(command).to have_attributes(**attributes)
    end
  end
end
