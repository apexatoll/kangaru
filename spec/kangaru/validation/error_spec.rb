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

  describe "#full_message" do
    subject(:full_message) { error.full_message }

    let(:messages) { { valid_validator => "is invalid" } }

    let(:valid_validator)   { :invalid }
    let(:invalid_validator) { :another }

    before do
      stub_const "#{described_class}::MESSAGES", messages
    end

    context "when message does not exist for given type" do
      let(:type) { invalid_validator }

      it "raises an error" do
        expect { full_message }.to raise_error("invalid message type")
      end
    end

    context "when message exists for given type" do
      let(:type) { valid_validator }

      it "does not raise any errors" do
        expect { full_message }.not_to raise_error
      end

      it "returns the expected string" do
        expect(full_message).to eq("Some attribute is invalid")
      end
    end
  end
end
