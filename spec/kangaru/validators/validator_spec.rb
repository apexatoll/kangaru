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

      def errors
        @errors ||= []
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

  describe "#add_error!" do
    subject(:add_error!) { validator.add_error!(type) }

    let(:type) { :some_error }

    it "adds an object to the model errors" do
      expect { add_error! }.to change { model.errors.count }.by(1)
    end

    it "adds an error object" do
      add_error!
      expect(model.errors.last).to be_a(Kangaru::Validation::Error)
    end

    it "sets the expected error attributes" do
      add_error!
      expect(model.errors.last).to have_attributes(attribute:, type:)
    end
  end
end
