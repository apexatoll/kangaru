RSpec.describe Kangaru::RequestBuilder do
  subject(:request_builder) { described_class.new(tokens) }

  describe "#build" do
    subject(:request) { request_builder.build }

    cases = {
      "" => {
        path: "/", params: {}
      },

      "123" => {
        path: "/123", params: {}
      },

      "foo" => {
        path: "/foo", params: {}
      },

      "foo 123" => {
        path: "/foo/123", params: {}
      },

      "foo bar" => {
        path: "/foo/bar", params: {}
      },

      "foo bar 123" => {
        path: "/foo/bar/123", params: {}
      },

      "foo bar baz" => {
        path: "/foo/bar/baz", params: {}
      },

      "--unary-arg" => {
        path: "/", params: { unary_arg: true }
      },

      "123 --unary-arg" => {
        path: "/123", params: { unary_arg: true }
      },

      "foo --unary-arg" => {
        path: "/foo", params: { unary_arg: true }
      },

      "foo 123 --unary-arg" => {
        path: "/foo/123", params: { unary_arg: true }
      },

      "foo bar --unary-arg" => {
        path: "/foo/bar", params: { unary_arg: true }
      },

      "foo bar 123 --unary-arg" => {
        path: "/foo/bar/123", params: { unary_arg: true }
      },

      "foo bar baz --unary-arg" => {
        path: "/foo/bar/baz", params: { unary_arg: true }
      },

      "-u" => {
        path: "/", params: { u: true }
      },

      "123 -u" => {
        path: "/123", params: { u: true }
      },

      "foo -u" => {
        path: "/foo", params: { u: true }
      },

      "foo 123 -u" => {
        path: "/foo/123", params: { u: true }
      },

      "foo bar -u" => {
        path: "/foo/bar", params: { u: true }
      },

      "foo bar 123 -u" => {
        path: "/foo/bar/123", params: { u: true }
      },

      "foo bar baz -u" => {
        path: "/foo/bar/baz", params: { u: true }
      },

      "--binary-arg hello world" => {
        path: "/", params: { binary_arg: "hello world" }
      },

      "123 --binary-arg hello world" => {
        path: "/123", params: { binary_arg: "hello world" }
      },

      "foo --binary-arg hello world" => {
        path: "/foo", params: { binary_arg: "hello world" }
      },

      "foo 123 --binary-arg hello world" => {
        path: "/foo/123", params: { binary_arg: "hello world" }
      },

      "foo bar --binary-arg hello world" => {
        path: "/foo/bar", params: { binary_arg: "hello world" }
      },

      "foo bar 123 --binary-arg hello world" => {
        path: "/foo/bar/123", params: { binary_arg: "hello world" }
      },

      "foo bar baz --binary-arg hello world" => {
        path: "/foo/bar/baz", params: { binary_arg: "hello world" }
      },

      "-b hello world" => {
        path: "/", params: { b: "hello world" }
      },

      "123 -b hello world" => {
        path: "/123", params: { b: "hello world" }
      },

      "foo -b hello world" => {
        path: "/foo", params: { b: "hello world" }
      },

      "foo 123 -b hello world" => {
        path: "/foo/123", params: { b: "hello world" }
      },

      "foo bar -b hello world" => {
        path: "/foo/bar", params: { b: "hello world" }
      },

      "foo bar 123 -b hello world" => {
        path: "/foo/bar/123", params: { b: "hello world" }
      },

      "foo bar baz -b hello world" => {
        path: "/foo/bar/baz", params: { b: "hello world" }
      },

      "foo 123 --name Foo Bar --cleanup -f" => {
        path: "/foo/123", params: { name: "Foo Bar", cleanup: true, f: true }
      }
    }

    cases.each do |command_string, expected|
      context "when '#{command_string}'" do
        let(:tokens) { command_string.split }

        %i[path params].each do |key|
          it "sets the #{key} to #{expected[key].inspect}" do
            expect(request).to have_attributes(key => expected[key])
          end
        end
      end
    end
  end
end
