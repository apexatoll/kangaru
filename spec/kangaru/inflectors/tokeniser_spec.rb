RSpec.describe Kangaru::Inflectors::Tokeniser do
  subject(:tokeniser) { described_class.new(string) }

  describe "#split" do
    subject(:tokens) { tokeniser.split }

    shared_examples :tokenises_string do |options|
      let(:expected_tokens) { options[:to] }

      it "returns the expected tokens" do
        expect(tokens).to eq(expected_tokens)
      end
    end

    describe "splitting groups" do
      context "when string has one word" do
        context "and no word delimiters" do
          let(:string) { "foobar" }

          include_examples :tokenises_string, to: [["foobar"]]
        end

        context "and a trailing path delimiter" do
          let(:string) { "foobar/" }

          include_examples :tokenises_string, to: [["foobar"]]
        end

        context "and a trailing namespace delimiter" do
          let(:string) { "foobar::" }

          include_examples :tokenises_string, to: [["foobar"]]
        end

        context "and a leading path delimiter" do
          let(:string) { "/foobar" }

          include_examples :tokenises_string, to: [[], ["foobar"]]
        end

        context "and a leading namespace delimiter" do
          let(:string) { "::foobar" }

          include_examples :tokenises_string, to: [[], ["foobar"]]
        end

        context "and leading and trailing path delimiters" do
          let(:string) { "/foobar/" }

          include_examples :tokenises_string, to: [[], ["foobar"]]
        end

        context "and leading and trailing namespace delimiters" do
          let(:string) { "::foobar::" }

          include_examples :tokenises_string, to: [[], ["foobar"]]
        end
      end

      context "when string has two words" do
        context "and a trailing path delimiter" do
          let(:string) { "foo/bar/" }

          include_examples :tokenises_string, to: [["foo"], ["bar"]]
        end

        context "and a trailing namespace delimiter" do
          let(:string) { "foo::bar::" }

          include_examples :tokenises_string, to: [["foo"], ["bar"]]
        end

        context "and a leading path delimiter" do
          let(:string) { "/foo/bar" }

          include_examples :tokenises_string, to: [[], ["foo"], ["bar"]]
        end

        context "and a leading namespace delimiter" do
          let(:string) { "::foo::bar" }

          include_examples :tokenises_string, to: [[], ["foo"], ["bar"]]
        end

        context "and leading and trailing path delimiters" do
          let(:string) { "/foo/bar/" }

          include_examples :tokenises_string, to: [[], ["foo"], ["bar"]]
        end

        context "and leading and trailing namespace delimiters" do
          let(:string) { "::foo::bar::" }

          include_examples :tokenises_string, to: [[], ["foo"], ["bar"]]
        end
      end
    end

    describe "splitting tokens" do
      context "when word contains two tokens" do
        context "and tokens delimited with an underscore" do
          let(:string) { "foo_bar" }

          include_examples :tokenises_string, to: [%w[foo bar]]
        end

        context "and tokens delimited with a hyphen" do
          let(:string) { "foo-bar" }

          include_examples :tokenises_string, to: [%w[foo bar]]
        end

        context "and tokens delimited using camel case" do
          let(:string) { "fooBar" }

          include_examples :tokenises_string, to: [%w[foo Bar]]
        end

        context "and tokens delimited using pascal case" do
          let(:string) { "FooBar" }

          include_examples :tokenises_string, to: [%w[Foo Bar]]
        end

        context "and tokens delimited using screaming snake case" do
          let(:string) { "FOO_BAR" }

          include_examples :tokenises_string, to: [%w[FOO BAR]]
        end

        context "and token delimiters are repeated" do
          let(:string) { "foo__bar" }

          include_examples :tokenises_string, to: [%w[foo bar]]
        end
      end
    end

    describe "splitting groups and tokens" do
      [
        { in: "foo/bar_baz.rb",  out: [["foo"], %w[bar baz.rb]] },
        { in: "/foo/bar_baz.rb", out: [[], ["foo"], %w[bar baz.rb]] },
        { in: "Foo::BarBaz", out: [["Foo"], %w[Bar Baz]] },
        { in: "::Foo::BarBaz", out: [[], ["Foo"], %w[Bar Baz]] }
      ].each do |params|
        context "when #{params[:in]}" do
          let(:string) { params[:in] }

          include_examples :tokenises_string, to: params[:out]
        end
      end
    end
  end
end
