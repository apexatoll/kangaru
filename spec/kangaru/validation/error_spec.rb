RSpec.describe Kangaru::Validation::Error do
  subject(:error) { described_class.new(**attributes) }

  let(:attributes) { { attribute:, message: } }

  let(:attribute) { :some_attribute }

  let(:message) { "is invalid" }

  describe "#initialize" do
    it "sets the attributes" do
      expect(error).to have_attributes(**attributes)
    end
  end

  describe "#full_message" do
    subject(:full_message) { error.full_message }

    it "does not raise any errors" do
      expect { full_message }.not_to raise_error
    end

    it "returns the expected string" do
      expect(full_message).to eq("Some attribute is invalid")
    end
  end
end
