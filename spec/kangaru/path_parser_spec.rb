RSpec.describe Kangaru::PathParser do
  subject(:path_parser) { described_class.new(path) }

  let(:path) { "/#{File.join(*tokens)}" }

  let(:tokens) { [*path_tokens, id_token].compact }

  shared_examples :parses_path do |expected|
    it "sets the controller to #{expected[:controller].inspect}" do
      expect(path_parser.controller).to eq(expected[:controller])
    end

    it "sets the action to #{expected[:action].inspect}" do
      expect(path_parser.action).to eq(expected[:action])
    end

    it "sets the id to #{expected[:id].inspect}" do
      expect(path_parser.id).to eq(expected[:id])
    end
  end

  context "when no path tokens are specified" do
    let(:path_tokens) { nil }

    context "and no id token is specified" do
      let(:id_token) { nil }

      include_examples :parses_path,
                       controller: nil, action: nil, id: nil
    end

    context "and id token is specified" do
      let(:id_token) { "123" }

      include_examples :parses_path,
                       controller: nil, action: nil, id: 123
    end
  end

  context "when one path token is specified" do
    let(:path_tokens) { %w[foo_bar] }

    context "and no id token is specified" do
      let(:id_token) { nil }

      include_examples :parses_path,
                       controller: nil, action: :foo_bar, id: nil
    end

    context "and id token is specified" do
      let(:id_token) { "123" }

      include_examples :parses_path,
                       controller: nil, action: :foo_bar, id: 123
    end
  end

  context "when two path tokens are specified" do
    let(:path_tokens) { %w[foo bar] }

    context "and no id token is specified" do
      let(:id_token) { nil }

      include_examples :parses_path,
                       controller: "foo", action: :bar, id: nil
    end

    context "and id token is specified" do
      let(:id_token) { "123" }

      include_examples :parses_path,
                       controller: "foo", action: :bar, id: 123
    end
  end

  context "when three path tokens are specified" do
    let(:path_tokens) { %w[foo bar baz] }

    context "and no id token is specified" do
      let(:id_token) { nil }

      include_examples :parses_path,
                       controller: "foo/bar", action: :baz, id: nil
    end

    context "and id token is specified" do
      let(:id_token) { "123" }

      include_examples :parses_path,
                       controller: "foo/bar", action: :baz, id: 123
    end
  end
end
