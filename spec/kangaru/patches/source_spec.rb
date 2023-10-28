RSpec.describe Kangaru::Patches::Source do
  using described_class

  describe ".source" do
    subject(:source) { target.source }

    describe Module do
      module SomeModule; end # rubocop:disable Lint,RSpec

      subject(:target) { SomeModule }

      it "returns a string" do
        expect(source).to be_a(String)
      end

      it "returns the expected source path" do
        expect(source).to eq(__FILE__)
      end
    end

    describe Class do
      class SomeClass; end # rubocop:disable Lint,RSpec

      subject(:target) { SomeClass }

      it "returns a string" do
        expect(source).to be_a(String)
      end

      it "returns the expected source path" do
        expect(source).to eq(__FILE__)
      end
    end
  end
end
