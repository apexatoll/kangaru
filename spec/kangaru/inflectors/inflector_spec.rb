RSpec.describe Kangaru::Inflectors::Inflector do
  subject(:inflector) { described_class.new(string) }

  let(:string) { nil }

  let(:tokeniser) do
    instance_double(Kangaru::Inflectors::Tokeniser, split: token_groups)
  end

  let(:inflector_params) do
    {
      "@token_transformer": token_transformer
    }.compact
  end

  let(:token_transformer) { nil }

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
    end
  end
end
