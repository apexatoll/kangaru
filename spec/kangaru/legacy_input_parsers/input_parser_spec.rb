RSpec.describe Kangaru::LegacyInputParsers::InputParser do
  subject(:input_parser) { described_class.new(tokens) }

  let(:tokens) { %w[foo bar baz] }

  describe "#parse" do
    subject(:parse) { input_parser.parse }

    it "raises a not implemented error (abstract method)" do
      expect { parse }.to raise_error(NotImplementedError)
    end
  end

  describe "#command_tokens" do
    subject(:command_tokens) { input_parser.command_tokens }

    context "when arguments are not passed" do
      let(:tokens) { %w[foo bar baz] }

      let(:expected_tokens) { %w[foo bar baz] }

      it "returns an array" do
        expect(command_tokens).to be_an(Array)
      end

      it "returns the expected tokens" do
        expect(command_tokens).to match_array(expected_tokens)
      end
    end

    context "when arguments are passed" do
      let(:tokens) { %w[foo bar baz --hello world --foobar] }

      let(:expected_tokens) { %w[foo bar baz] }

      it "returns an array" do
        expect(command_tokens).to be_an(Array)
      end

      it "returns the expected_tokens" do
        expect(command_tokens).to match_array(expected_tokens)
      end
    end
  end

  describe "#argument_tokens" do
    subject(:argument_tokens) { input_parser.argument_tokens }

    context "when arguments are not passed" do
      let(:tokens) { %w[foo bar baz] }

      it "returns an array" do
        expect(argument_tokens).to be_an(Array)
      end

      it "is empty" do
        expect(argument_tokens).to be_empty
      end
    end

    context "when arguments are passed" do
      let(:tokens) { %w[foo bar baz --hello world --foobar] }

      let(:expected_tokens) { %w[--hello world --foobar] }

      it "returns an array" do
        expect(argument_tokens).to be_an(Array)
      end

      it "returns the expected_tokens" do
        expect(argument_tokens).to match_array(expected_tokens)
      end
    end
  end
end
