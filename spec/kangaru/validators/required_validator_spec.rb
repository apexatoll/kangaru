RSpec.describe Kangaru::Validators::RequiredValidator do
  subject(:validator) { described_class.new(**attributes) }

  let(:attributes) { { model:, attribute:, params: } }

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

  let(:model) { ModelClass.new(attribute => value) }

  let(:attribute) { :some_attribute }

  let(:params) { {} }

  before do
    stub_const "ModelClass", model_class

    stub_const "Kangaru::Validation::Error::MESSAGES",
               { blank: "can't be blank" }
  end

  describe "#validate" do
    subject(:validate) { validator.validate }

    shared_examples :invalid do
      it "does not raise any errors" do
        expect { validate }.not_to raise_error
      end

      it "sets an error" do
        expect { validate }.to change { model.errors.count }.by(1)
      end

      it "sets the expected error" do
        validate
        expect(model.errors.last.full_message).to eq(
          "Some attribute can't be blank"
        )
      end
    end

    shared_examples :valid do
      it "does not raise any errors" do
        expect { validate }.not_to raise_error
      end

      it "does not set any errors" do
        expect { validate }.not_to change { model.errors }
      end
    end

    context "when value is nil" do
      let(:value) { nil }

      include_examples :invalid
    end

    context "when value is a blank string" do
      let(:value) { "" }

      include_examples :invalid
    end

    context "when value is false" do
      let(:value) { false }

      include_examples :invalid
    end

    context "when value is present" do
      let(:value) { :present }

      include_examples :valid
    end
  end
end
