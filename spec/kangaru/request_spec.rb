RSpec.describe Kangaru::Request do
  subject(:request) { described_class.new(**attributes) }

  let(:attributes) { { path:, params: }.compact }

  let(:path) { "/foo/bar/baz" }

  let(:params) { { foo: "foo", bar: "bar" } }

  describe "#initialize" do
    it "sets the attributes" do
      expect(request).to have_attributes(**attributes)
    end
  end
end
