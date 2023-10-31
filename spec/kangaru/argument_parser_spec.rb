RSpec.describe Kangaru::ArgumentParser do
  subject(:argument_parser) { described_class.new(*tokens) }

  describe "#parse" do
    subject(:parse) { argument_parser.parse }

    shared_examples :parses_arguments do |**options|
      it "returns a hash" do
        expect(parse).to be_a(Hash)
      end

      it "has symbol keys" do
        expect(parse.keys).to all be_a(Symbol)
      end

      it "sets the expected value" do
        expect(parse).to eq(options)
      end

      it "does not mutate the tokens" do
        expect { parse }.not_to change { argument_parser.tokens }
      end
    end

    context "when no arguments are passed" do
      let(:tokens) { [] }

      include_examples :parses_arguments, {}
    end

    context "when single unary argument is passed" do
      context "and terse flag form given" do
        let(:tokens) { ["-f"] }

        include_examples :parses_arguments, f: true
      end

      context "and verbose flag form given" do
        let(:tokens) { ["--foo-bar"] }

        include_examples :parses_arguments, foo_bar: true
      end
    end

    context "when single binary argument is passed" do
      context "and terse flag form given" do
        let(:tokens) { %w[-t Hello world] }

        include_examples :parses_arguments, t: "Hello world"
      end

      context "and verbose flag form given" do
        let(:tokens) { %w[--full-title Hello world] }

        include_examples :parses_arguments, full_title: "Hello world"
      end
    end

    context "and multiple arguments are passed" do
      let(:tokens) do
        %w[--title This is the title -d Foobar --cleanup]
      end

      include_examples :parses_arguments,
                       title: "This is the title", d: "Foobar", cleanup: true
    end
  end
end
