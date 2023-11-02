RSpec.describe Kangaru::Validators::Validator do
  subject(:validator) { described_class.new(**attributes) }

  let(:attributes) { { model:, attribute:, params: } }

  let(:model) { ModelClass.new(attribute => value) }

  let(:model_class) do
    Class.new do
      attr_reader :some_attribute

      def initialize(some_attribute:)
        @some_attribute = some_attribute
      end
    end
  end

  let(:attribute) { :some_attribute }

  let(:value) { :value }

  let(:params) { {} }

  before { stub_const "ModelClass", model_class }

  describe "#initialize" do
    it "sets the attributes" do
      expect(validator).to have_attributes(**attributes)
    end

    it "reads the value from the model" do
      expect(validator.value).to eq(value)
    end
  end

  describe "#validate" do
    subject(:validate) { validator.validate }

    it "raises an not implemented error" do
      expect { validate }.to raise_error(NotImplementedError)
    end
  end
end
