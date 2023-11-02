RSpec.describe Kangaru::Validation::Error do
  subject(:error) { described_class.new(**attributes) }

  let(:attributes) { { attribute:, type: } }

  let(:attribute) { :some_attribute }

  let(:type) { :some_error }

  describe "#initialize" do
    it "sets the attributes" do
      expect(error).to have_attributes(**attributes)
    end
  end
end
