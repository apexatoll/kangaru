RSpec.describe Kangaru::Validation::ModelValidator do
  subject(:model_validator) { described_class.new(model:) }

  let(:model) { instance_spy(Object) }

  let(:foo_attribute) { :foo }

  let(:foo_attribute_validator) do
    instance_spy(Kangaru::Validation::AttributeValidator)
  end

  let(:bar_attribute) { :bar }

  let(:bar_attribute_validator) do
    instance_spy(Kangaru::Validation::AttributeValidator)
  end

  before do
    allow(Kangaru::Validation::AttributeValidator)
      .to receive(:new)
      .with(model:, attribute: foo_attribute)
      .and_return(foo_attribute_validator)

    allow(Kangaru::Validation::AttributeValidator)
      .to receive(:new)
      .with(model:, attribute: bar_attribute)
      .and_return(bar_attribute_validator)
  end

  describe "#validate!" do
    subject(:validate!) { model_validator.validate!(**rules) }

    context "when no attributes are validated" do
      let(:rules) { {} }

      it "does not raise any errors" do
        expect { validate! }.not_to raise_error
      end

      it "does not instantiate an attribute validator" do
        validate!

        expect(Kangaru::Validation::AttributeValidator)
          .not_to have_received(:new)
      end
    end

    context "when one attribute is validated" do
      let(:rules) { { attribute => validations } }

      let(:attribute) { foo_attribute }

      let(:validations) { { required: true, integer: true } }

      it "does not raise any errors" do
        expect { validate! }.not_to raise_error
      end

      it "instantiates one attribute validator" do
        validate!

        expect(Kangaru::Validation::AttributeValidator)
          .to have_received(:new)
          .once
      end

      it "instantiates the expected attribute validator" do
        validate!

        expect(Kangaru::Validation::AttributeValidator)
          .to have_received(:new)
          .with(model:, attribute:)
          .once
      end

      it "runs the attribute validations" do
        validate!

        expect(foo_attribute_validator)
          .to have_received(:validate!)
          .with(**validations)
          .once
      end
    end

    context "when two attributes are validated" do
      let(:rules) do
        {
          attribute_one => validations_one,
          attribute_two => validations_two
        }
      end

      let(:attribute_one) { foo_attribute }
      let(:attribute_two) { bar_attribute }

      let(:validations_one) { { required: true } }
      let(:validations_two) { { integer: true } }

      it "does not raise any errors" do
        expect { validate! }.not_to raise_error
      end

      it "instantiates two attribute validators" do
        validate!

        expect(Kangaru::Validation::AttributeValidator)
          .to have_received(:new)
          .twice
      end

      it "instantiates the first attribute validator" do
        validate!

        expect(Kangaru::Validation::AttributeValidator)
          .to have_received(:new)
          .with(model:, attribute: attribute_one)
          .once
      end

      it "runs the first attribute validations" do
        validate!

        expect(foo_attribute_validator)
          .to have_received(:validate!)
          .with(**validations_one)
          .once
      end

      it "instantiates the second attribute validator" do
        validate!

        expect(Kangaru::Validation::AttributeValidator)
          .to have_received(:new)
          .with(model:, attribute: attribute_two)
          .once
      end

      it "runs the second attribute validations" do
        validate!

        expect(bar_attribute_validator)
          .to have_received(:validate!)
          .with(**validations_two)
          .once
      end
    end
  end
end
