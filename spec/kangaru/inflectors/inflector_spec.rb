RSpec.describe Kangaru::Inflectors::Inflector do
  subject(:inflector) { described_class.new(string) }

  let(:string) { nil }

  let(:tokeniser) do
    instance_double(Kangaru::Inflectors::Tokeniser, split: token_groups)
  end

  let(:inflector_params) do
    {
      "@token_transformer": token_transformer,
      "@token_joiner": token_joiner,
      "@group_joiner": group_joiner
    }.compact
  end

  let(:token_transformer) { nil }
  let(:token_joiner)      { nil }
  let(:group_joiner)      { nil }

  around do |spec|
    inflector_params.each do |key, value|
      described_class.instance_variable_set(key, value)
    end

    spec.run

    inflector_params.each_key do |key|
      described_class.remove_instance_variable(key)
    end
  end

  before do
    allow(Kangaru::Inflectors::Tokeniser).to receive(:new).and_return(tokeniser)
  end

  describe "#inflect" do
    subject(:inflection) { inflector.inflect }

    shared_examples :inflects do |options|
      it "inflects to #{options[:to]}" do
        expect(inflection).to eq(options[:to])
      end
    end

    context "when string consists of one word" do
      let(:token_groups) { [tokens] }

      context "and word consists of one token" do
        let(:tokens) { [token] }
        let(:token)  { "foobar" }

        context "and no token transformer is set" do
          let(:token_transformer) { nil }

          include_examples :inflects, to: "foobar"
        end

        context "and token transformer is a proc" do
          let(:token_transformer) { ->(token) { token.reverse } }

          include_examples :inflects, to: "raboof"
        end

        context "and token transformer is a symbol" do
          let(:token_transformer) { :upcase }

          include_examples :inflects, to: "FOOBAR"
        end
      end

      context "and word consists of multiple tokens" do
        let(:tokens) { %w[foo bar baz] }

        context "and token transformer is not set" do
          let(:token_transformer) { nil }

          context "and token joiner is not set" do
            let(:token_joiner) { nil }

            include_examples :inflects, to: "foobarbaz"
          end

          context "and token joiner is set" do
            let(:token_joiner) { "_" }

            include_examples :inflects, to: "foo_bar_baz"
          end
        end

        context "and token transformer is a proc" do
          let(:token_transformer) { ->(token) { token.capitalize } }

          context "and token joiner is not set" do
            let(:token_joiner) { nil }

            include_examples :inflects, to: "FooBarBaz"
          end

          context "and token joiner is set" do
            let(:token_joiner) { "_" }

            include_examples :inflects, to: "Foo_Bar_Baz"
          end
        end

        context "and token transformer is a symbol" do
          let(:token_transformer) { :upcase }

          context "and token joiner is not set" do
            let(:token_joiner) { nil }

            include_examples :inflects, to: "FOOBARBAZ"
          end

          context "and token joiner is set" do
            let(:token_joiner) { "_" }

            include_examples :inflects, to: "FOO_BAR_BAZ"
          end
        end
      end
    end

    context "when string consists of multiple words" do
      context "and first word is empty" do
        let(:token_groups) { [[], %w[foo bar], %w[baz]] }

        context "and token transformer is not set" do
          let(:token_transformer) { nil }

          context "and token joiner is not set" do
            let(:token_joiner) { nil }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "/foobar/baz"
            end

            context "and group joiner is set" do
              let(:group_joiner) { "::" }

              include_examples :inflects, to: "::foobar::baz"
            end
          end

          context "and token joiner is set" do
            let(:token_joiner) { "." }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "/foo.bar/baz"
            end

            context "and group joiner is set" do
              let(:group_joiner) { "::" }

              include_examples :inflects, to: "::foo.bar::baz"
            end
          end
        end

        context "and token transformer is a proc" do
          let(:token_transformer) { ->(token) { token.capitalize } }

          context "and token joiner is not set" do
            let(:token_joiner) { nil }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "/FooBar/Baz"
            end
          end

          context "and token joiner is set" do
            let(:token_joiner) { "-" }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "/Foo-Bar/Baz"
            end
          end
        end

        context "and token transformer is a symbol" do
          let(:token_transformer) { :capitalize }

          context "and token joiner is not set" do
            let(:token_joiner) { nil }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "/FooBar/Baz"
            end
          end

          context "and token joiner is set" do
            let(:token_joiner) { "-" }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "/Foo-Bar/Baz"
            end
          end
        end
      end

      context "and first word is not empty" do
        let(:token_groups) { [%w[foo bar], %w[baz]] }

        context "and token transformer is not set" do
          let(:token_transformer) { nil }

          context "and token joiner is not set" do
            let(:token_joiner) { nil }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "foobar/baz"
            end

            context "and group joiner is set" do
              let(:group_joiner) { "::" }

              include_examples :inflects, to: "foobar::baz"
            end
          end

          context "and token joiner is set" do
            let(:token_joiner) { "." }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "foo.bar/baz"
            end

            context "and group joiner is set" do
              let(:group_joiner) { "::" }

              include_examples :inflects, to: "foo.bar::baz"
            end
          end
        end

        context "and token transformer is a proc" do
          let(:token_transformer) { ->(token) { token.capitalize } }

          context "and token joiner is not set" do
            let(:token_joiner) { nil }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "FooBar/Baz"
            end
          end

          context "and token joiner is set" do
            let(:token_joiner) { "-" }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "Foo-Bar/Baz"
            end
          end
        end

        context "and token transformer is a symbol" do
          let(:token_transformer) { :capitalize }

          context "and token joiner is not set" do
            let(:token_joiner) { nil }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "FooBar/Baz"
            end
          end

          context "and token joiner is set" do
            let(:token_joiner) { "-" }

            context "and group joiner is not set" do
              let(:group_joiner) { nil }

              include_examples :inflects, to: "Foo-Bar/Baz"
            end
          end
        end
      end
    end
  end
end
