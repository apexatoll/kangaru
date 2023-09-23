RSpec.describe Kangaru::Testing::Gem, :with_temp_dir do
  subject(:gem) { described_class.new(**attributes) }

  let(:attributes) { { dir:, name: }.compact }

  let(:name) { "some_gem" }
  let(:dir)  { temp_dir }

  describe "#initialize" do
    context "when gem name is not specified" do
      let(:name) { nil }

      it "sets the directory" do
        expect(gem.dir).to eq(dir)
      end

      it "sets the name to the default" do
        expect(gem.name).to eq(described_class::DEFAULT_NAME)
      end
    end

    context "when gem name is specified" do
      let(:name) { "some_gem" }

      it "sets the directory" do
        expect(gem.dir).to eq(dir)
      end

      it "sets the name to the specified value" do
        expect(gem.name).to eq(name)
      end
    end
  end
end
