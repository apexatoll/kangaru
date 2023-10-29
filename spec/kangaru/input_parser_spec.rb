RSpec.describe Kangaru::InputParser do
  subject(:input_parser) { described_class.new(*tokens) }

  describe "#parse" do
    subject(:command) { input_parser.parse }

    def self.default_path = Kangaru::Command::DEFAULT_PATH

    def self.default_action = Kangaru::Command::DEFAULT_ACTION

    cases = {
      # No tokens
      "" => {
        path: default_path, action: default_action, id: nil,
        arguments: {}
      },

      # Command tokens only
      "foo" => {
        path: default_path, action: :foo, id: nil,
        arguments: {}
      },

      "foo bar" => {
        path: "foo", action: :bar, id: nil,
        arguments: {}
      },

      "foo bar baz" => {
        path: "foo/bar", action: :baz, id: nil,
        arguments: {}
      },

      # Command tokens include an ID
      "123" => {
        path: default_path, action: default_action, id: 123,
        arguments: {}
      },

      "foo 123" => {
        path: default_path, action: :foo, id: 123,
        arguments: {}
      },

      "foo bar 123" => {
        path: "foo", action: :bar, id: 123,
        arguments: {}
      },

      "foo bar baz 123" => {
        path: "foo/bar", action: :baz, id: 123,
        arguments: {}
      },

      # Command tokens without id with verbose unary arg
      "foo --unary-arg" => {
        path: default_path, action: :foo, id: nil,
        arguments: { unary_arg: true }
      },

      "foo bar --unary-arg" => {
        path: "foo", action: :bar, id: nil,
        arguments: { unary_arg: true }
      },

      "foo bar baz --unary-arg" => {
        path: "foo/bar", action: :baz, id: nil,
        arguments: { unary_arg: true }
      },

      # Command tokens with id with verbose unary arg
      "123 --unary-arg" => {
        path: default_path, action: default_action, id: 123,
        arguments: { unary_arg: true }
      },

      "foo 123 --unary-arg" => {
        path: default_path, action: :foo, id: 123,
        arguments: { unary_arg: true }
      },

      "foo bar 123 --unary-arg" => {
        path: "foo", action: :bar, id: 123,
        arguments: { unary_arg: true }
      },

      "foo bar baz 123 --unary-arg" => {
        path: "foo/bar", action: :baz, id: 123,
        arguments: { unary_arg: true }
      },

      # Command tokens without id with terse unary arg
      "foo -u" => {
        path: default_path, action: :foo, id: nil,
        arguments: { u: true }
      },

      "foo bar -u" => {
        path: "foo", action: :bar, id: nil,
        arguments: { u: true }
      },

      "foo bar baz -u" => {
        path: "foo/bar", action: :baz, id: nil,
        arguments: { u: true }
      },

      # Command tokens with id with terse unary arg
      "123 -u" => {
        path: default_path, action: default_action, id: 123,
        arguments: { u: true }
      },

      "foo 123 -u" => {
        path: default_path, action: :foo, id: 123,
        arguments: { u: true }
      },

      "foo bar 123 -u" => {
        path: "foo", action: :bar, id: 123,
        arguments: { u: true }
      },

      "foo bar baz 123 -u" => {
        path: "foo/bar", action: :baz, id: 123,
        arguments: { u: true }
      },

      # Command tokens without id with verbose binary arg
      "foo --binary-arg hello world" => {
        path: default_path, action: :foo, id: nil,
        arguments: { binary_arg: "hello world" }
      },

      "foo bar --binary-arg hello world" => {
        path: "foo", action: :bar, id: nil,
        arguments: { binary_arg: "hello world" }
      },

      "foo bar baz --binary-arg hello world" => {
        path: "foo/bar", action: :baz, id: nil,
        arguments: { binary_arg: "hello world" }
      },

      # Command tokens with id with verbose binary arg
      "123 --binary-arg hello world" => {
        path: default_path, action: default_action, id: 123,
        arguments: { binary_arg: "hello world" }
      },

      "foo 123 --binary-arg hello world" => {
        path: default_path, action: :foo, id: 123,
        arguments: { binary_arg: "hello world" }
      },

      "foo bar 123 --binary-arg hello world" => {
        path: "foo", action: :bar, id: 123,
        arguments: { binary_arg: "hello world" }
      },

      "foo bar baz 123 --binary-arg hello world" => {
        path: "foo/bar", action: :baz, id: 123,
        arguments: { binary_arg: "hello world" }
      },

      # Command tokens without id with terse binary arg
      "foo -b hello world" => {
        path: default_path, action: :foo, id: nil,
        arguments: { b: "hello world" }
      },

      "foo bar -b hello world" => {
        path: "foo", action: :bar, id: nil,
        arguments: { b: "hello world" }
      },

      "foo bar baz -b hello world" => {
        path: "foo/bar", action: :baz, id: nil,
        arguments: { b: "hello world" }
      },

      # Command tokens with id with terse binary arg
      "123 -b hello world" => {
        path: default_path, action: default_action, id: 123,
        arguments: { b: "hello world" }
      },

      "foo 123 -b hello world" => {
        path: default_path, action: :foo, id: 123,
        arguments: { b: "hello world" }
      },

      "foo bar 123 -b hello world" => {
        path: "foo", action: :bar, id: 123,
        arguments: { b: "hello world" }
      },

      "foo bar baz 123 -b hello world" => {
        path: "foo/bar", action: :baz, id: 123,
        arguments: { b: "hello world" }
      },

      # Verbose unary arguments only
      "--unary-arg" => {
        path: default_path, action: default_action, id: nil,
        arguments: { unary_arg: true }
      },

      # Terse unary arguments only
      "-u" => {
        path: default_path, action: default_action, id: nil,
        arguments: { u: true }
      },

      # Verbose binary arguments only
      "--binary-arg hello world" => {
        path: default_path, action: default_action, id: nil,
        arguments: { binary_arg: "hello world" }
      },

      # Terse binary arguments only
      "-b hello world" => {
        path: default_path, action: default_action, id: nil,
        arguments: { b: "hello world" }
      }
    }

    cases.each do |command_string, expected|
      context "when '#{command_string}'" do
        let(:tokens) { command_string.split }

        %i[path action id arguments].each do |key|
          it "sets the #{key} to #{expected[key].inspect}" do
            expect(command).to have_attributes(key => expected[key])
          end
        end
      end
    end
  end
end
