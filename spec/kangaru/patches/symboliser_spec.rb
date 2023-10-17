RSpec.describe Kangaru::Patches::Symboliser do
  using described_class

  describe "#symbolise" do
    describe Hash do
      subject(:symbolised) { hash.symbolise }

      context "when hash is a flat string-keyed hash" do
        let(:hash) { { "foo" => "bar", "bar" => "baz", "baz" => "foo" } }

        it "returns the expected symbolised hash" do
          expect(symbolised).to eq(foo: "bar", bar: "baz", baz: "foo")
        end
      end

      context "when hash is a nested string-keyed hash" do
        let(:hash) { { "foo" => { "bar" => "baz" }, "baz" => "foo" } }

        it "returns the expected symbolised hash" do
          expect(symbolised).to eq(foo: { bar: "baz" }, baz: "foo")
        end
      end

      context "when string hash contains arrays of string hashes" do
        let(:hash) { { "foo" => [{ "bar" => "baz" }, { "baz" => "foo" }] } }

        it "returns the expected symbolised hash" do
          expect(symbolised).to eq(foo: [{ bar: "baz" }, { baz: "foo" }])
        end
      end

      context "when string hash contains arrays of symbol hashes" do
        let(:hash) { { "foo" => [{ bar: "baz" }, { baz: "foo" }] } }

        it "returns the expected symbolised hash" do
          expect(symbolised).to eq(foo: [{ bar: "baz" }, { baz: "foo" }])
        end
      end

      context "when symbol hash contains arrays of string hashes" do
        let(:hash) { { foo: [{ "bar" => "baz" }, { "baz" => "foo" }] } }

        it "returns the expected symbolised hash" do
          expect(symbolised).to eq(foo: [{ bar: "baz" }, { baz: "foo" }])
        end
      end
    end

    describe Array do
      subject(:symbolised) { array.symbolise }

      context "when array does not contain hashes" do
        let(:array) { %w[foo bar baz] }

        it "returns the array unchanged" do
          expect(symbolised).to eq(array)
        end
      end

      context "when array contains hashes" do
        let(:array) { [{ "bar" => "baz" }, { "baz" => "foo" }] }

        it "returns the expected symbolised hashes" do
          expect(symbolised).to eq([{ bar: "baz" }, { baz: "foo" }])
        end
      end
    end
  end
end
