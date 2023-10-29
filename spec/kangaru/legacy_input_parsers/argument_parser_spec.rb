RSpec.describe Kangaru::LegacyInputParsers::ArgumentParser do
  subject(:argument_parser) { described_class.new(tokens) }

  let(:tokens) { [command_tokens, argument_tokens].flatten.compact }

  describe "#parse" do
    subject(:arguments) { argument_parser.parse }

    shared_examples :parses_arguments_hash do |options|
      let(:expected_hash) { options[:to] }

      it "returns a hash" do
        expect(arguments).to be_a(Hash)
      end

      it "has symbol keys" do
        expect(arguments.keys).to all be_a(Symbol)
      end

      it "is the expected hash" do
        expect(arguments).to eq(expected_hash)
      end
    end

    context "when input does not contain command tokens" do
      let(:command_tokens) { nil }

      context "and single unary argument is passed" do
        context "and terse flag form given" do
          let(:argument_tokens) { ["-f"] }

          include_examples :parses_arguments_hash, to: { f: true }
        end

        context "and verbose flag form given" do
          let(:argument_tokens) { ["--foo-bar"] }

          include_examples :parses_arguments_hash, to: { foo_bar: true }
        end
      end

      context "and single binary argument is passed" do
        context "and terse flag form given" do
          let(:argument_tokens) { %w[-t Hello world] }

          include_examples :parses_arguments_hash, to: { t: "Hello world" }
        end

        context "and verbose flag form given" do
          let(:argument_tokens) { %w[--full-title Hello world] }

          include_examples :parses_arguments_hash,
                           to: { full_title: "Hello world" }
        end
      end

      context "and multiple arguments are passed" do
        let(:argument_tokens) do
          %w[--title This is the title -d Foobar --cleanup -f]
        end

        include_examples :parses_arguments_hash, to: {
          title: "This is the title", d: "Foobar", cleanup: true, f: true
        }
      end
    end

    context "when input contains command tokens" do
      let(:command_tokens) { %w[foo bar baz] }

      context "and single unary argument is passed" do
        context "and terse flag form given" do
          let(:argument_tokens) { ["-f"] }

          include_examples :parses_arguments_hash, to: { f: true }
        end

        context "and verbose flag form given" do
          let(:argument_tokens) { ["--foo-bar"] }

          include_examples :parses_arguments_hash, to: { foo_bar: true }
        end
      end

      context "and single binary argument is passed" do
        context "and terse flag form given" do
          let(:argument_tokens) { %w[-t Hello world] }

          include_examples :parses_arguments_hash, to: { t: "Hello world" }
        end

        context "and verbose flag form given" do
          let(:argument_tokens) { %w[--full-title Hello world] }

          include_examples :parses_arguments_hash,
                           to: { full_title: "Hello world" }
        end
      end

      context "and multiple arguments are passed" do
        let(:argument_tokens) do
          %w[--title This is the title -d Foobar --cleanup -f]
        end

        include_examples :parses_arguments_hash, to: {
          title: "This is the title", d: "Foobar", cleanup: true, f: true
        }
      end
    end
  end
end
