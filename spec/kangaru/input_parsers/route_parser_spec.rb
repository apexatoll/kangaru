RSpec.describe Kangaru::InputParsers::RouteParser do
  subject(:route_parser) { described_class.new(*tokens) }

  describe "#parse" do
    subject(:parse) { route_parser.parse }

    shared_examples :parses_command do |expected|
      it "returns a hash" do
        expect(parse).to be_a(Hash)
      end

      it "contains the expected keys" do
        expect(parse.keys).to contain_exactly(:path, :action, :id)
      end

      it "sets the expected values" do
        expect(parse).to eq(expected)
      end

      it "does not mutate the tokens" do
        expect { parse }.not_to change { route_parser.tokens }
      end
    end

    context "when no tokens are specified" do
      let(:tokens) { [] }

      include_examples :parses_command,
                       path: nil, action: nil, id: nil
    end

    context "when one token is specified" do
      let(:tokens) { [last_token] }

      context "and last token is not an id" do
        let(:last_token) { "foo" }

        include_examples :parses_command,
                         path: nil, action: :foo, id: nil
      end

      context "and last token is an id" do
        let(:last_token) { "123" }

        include_examples :parses_command,
                         path: nil, action: nil, id: 123
      end
    end

    context "when two tokens are specified" do
      let(:tokens) { ["foo", last_token] }

      context "and last token is not an id" do
        let(:last_token) { "bar" }

        include_examples :parses_command,
                         path: "foo", action: :bar, id: nil
      end

      context "and last token is an id" do
        let(:last_token) { "123" }

        include_examples :parses_command,
                         path: nil, action: :foo, id: 123
      end
    end

    context "when three tokens are specified" do
      let(:tokens) { ["foo", "bar", last_token] }

      context "and last token is not an id" do
        let(:last_token) { "baz" }

        include_examples :parses_command,
                         path: "foo/bar", action: :baz, id: nil
      end

      context "and last token is an id" do
        let(:last_token) { "123" }

        include_examples :parses_command,
                         path: "foo", action: :bar, id: 123
      end
    end

    context "when four tokens are specified" do
      let(:tokens) { ["foo", "bar", "baz", last_token] }

      context "and last token is not an id" do
        let(:last_token) { "far" }

        include_examples :parses_command,
                         path: "foo/bar/baz", action: :far, id: nil
      end

      context "and last token is an id" do
        let(:last_token) { "123" }

        include_examples :parses_command,
                         path: "foo/bar", action: :baz, id: 123
      end
    end
  end
end
