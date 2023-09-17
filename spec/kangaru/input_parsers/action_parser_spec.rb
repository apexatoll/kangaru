RSpec.describe Kangaru::InputParsers::ActionParser do
  subject(:action_parser) { described_class.new(tokens) }

  let(:tokens) { [command_tokens, argument_tokens].flatten.compact }

  describe "#parse" do
    subject(:action) { action_parser.parse }

    context "when input does not contain argument tokens" do
      let(:argument_tokens) { nil }

      context "and no command tokens passed" do
        let(:command_tokens) { nil }

        it "returns the default action" do
          expect(action).to eq(described_class::DEFAULT_ACTION)
        end
      end

      context "and one command token passed" do
        let(:command_tokens) { ["foo"] }

        it "returns the default action" do
          expect(action).to eq(described_class::DEFAULT_ACTION)
        end
      end

      context "and two command token passed" do
        let(:command_tokens) { %w[foo bar-baz] }

        it "returns the expected action" do
          expect(action).to eq(:bar_baz)
        end
      end

      context "and three command token passed" do
        let(:command_tokens) { %w[foo bar baz] }

        it "returns the expected action" do
          expect(action).to eq(:baz)
        end
      end
    end

    context "when input contains argument tokens" do
      let(:argument_tokens) { %w[--title foobar --all] }

      context "and no command tokens passed" do
        let(:command_tokens) { nil }

        it "returns the default action" do
          expect(action).to eq(described_class::DEFAULT_ACTION)
        end
      end

      context "and one command token passed" do
        let(:command_tokens) { ["foo"] }

        it "returns the default action" do
          expect(action).to eq(described_class::DEFAULT_ACTION)
        end
      end

      context "and two command token passed" do
        let(:command_tokens) { %w[foo bar-baz] }

        it "returns the expected action" do
          expect(action).to eq(:bar_baz)
        end
      end

      context "and three command token passed" do
        let(:command_tokens) { %w[foo bar baz] }

        it "returns the expected action" do
          expect(action).to eq(:baz)
        end
      end
    end
  end
end
