RSpec.describe Kangaru::Patches::Constantise do
  using described_class

  let(:constantiser) { Kangaru::Inflectors::Constantiser }

  let(:value) { "value" }

  before do
    allow(constantiser).to receive(:constantise).and_return(value)
  end

  describe String do
    let(:string) { "foo/bar" }

    describe "#constantise" do
      subject(:constant) { string.constantise }

      it "delegates to the Constantiser class" do
        constant
        expect(constantiser).to have_received(:constantise).with(string).once
      end

      it "returns the value from the constantiser" do
        expect(constant).to eq(value)
      end
    end
  end
end
