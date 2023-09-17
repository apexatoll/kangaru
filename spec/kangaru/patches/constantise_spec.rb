RSpec.describe Kangaru::Patches::Constantise do
  using described_class

  let(:constantiser) { instance_double(constantiser_class, constantise: value) }

  let(:constantiser_class) { Kangaru::Inflectors::Constantiser }

  let(:value) { "value" }

  before do
    allow(constantiser_class).to receive(:new).and_return(constantiser)
  end

  describe String do
    let(:string) { "foo/bar" }

    describe "#constantise" do
      subject(:constant) { string.constantise }

      it "instantiates a constantiser" do
        constant
        expect(constantiser_class).to have_received(:new).with(string).once
      end

      it "delegates to the constantiser" do
        constant
        expect(constantiser).to have_received(:constantise).once
      end

      it "returns the value from the constantiser" do
        expect(constant).to eq(value)
      end
    end
  end
end
