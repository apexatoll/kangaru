RSpec.describe Kangaru::InputParsers::ControllerParser do
  let(:controller_parser) { described_class.new(tokens) }

  let(:tokens) { [command_tokens, argument_tokens].flatten.compact }

  describe "#parse" do
    subject(:controller) { controller_parser.parse }

    context "when input does not contain argument tokens" do
      let(:argument_tokens) { nil }

      context "and no command tokens passed" do
        let(:command_tokens) { [] }

        it "returns the default controller" do
          expect(controller).to eq(described_class::DEFAULT_CONTROLLER)
        end
      end

      context "and one command token passed" do
        let(:command_tokens) { ["foo"] }

        it "returns the expected controller" do
          expect(controller).to eq("FooController")
        end
      end

      context "and two command tokens passed" do
        let(:command_tokens) { %w[foo bar] }

        it "returns the expected controller" do
          expect(controller).to eq("FooController")
        end
      end

      context "and three command tokens passed" do
        let(:command_tokens) { %w[foo bar baz] }

        it "returns the expected controller" do
          expect(controller).to eq("Foo::BarController")
        end
      end
    end

    context "when input contains argument tokens" do
      let(:argument_tokens) { %w[--title Hello world --force --cleanup] }

      context "and no command tokens passed" do
        let(:command_tokens) { [] }

        it "returns the default controller" do
          expect(controller).to eq(described_class::DEFAULT_CONTROLLER)
        end
      end

      context "and one command token passed" do
        let(:command_tokens) { ["foo"] }

        it "returns the expected controller" do
          expect(controller).to eq("FooController")
        end
      end

      context "and two command tokens passed" do
        let(:command_tokens) { %w[foo bar] }

        it "returns the expected controller" do
          expect(controller).to eq("FooController")
        end
      end

      context "and three command tokens passed" do
        let(:command_tokens) { %w[foo bar baz] }

        it "returns the expected controller" do
          expect(controller).to eq("Foo::BarController")
        end
      end
    end
  end
end
