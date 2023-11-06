RSpec.describe Kangaru::Concerns::Validatable do
  subject(:validatable) { validatable_class.new }

  let(:validatable_class) do
    Class.new { include Kangaru::Concerns::Validatable }
  end

  describe ".validates" do
    subject(:validates) do
      validatable_class.validates(attribute, **validations)
    end

    after do
      validatable_class.remove_instance_variable(:@validations)
    end

    let(:attribute) { :some_attribute }

    context "when one validation rule is specified" do
      let(:validations) { { validator_name => params } }

      let(:validator_name) { :some_validator }

      context "and validation params are not specified" do
        let(:params) { true }

        it "sets the expected validations" do
          expect { validates }
            .to change { validatable_class.validations }
            .to(attribute => { validator_name => true })
        end
      end

      context "and validation params are specified" do
        let(:params) { { foo: "foo" } }

        it "sets the expected validations" do
          expect { validates }
            .to change { validatable_class.validations }
            .to(attribute => { validator_name => params })
        end
      end
    end

    context "when two validation rules are specified" do
      let(:validations) { { validator_one => true, validator_two => true } }

      let(:validator_one) { :some_validator }
      let(:validator_two) { :another_validator }

      it "sets the expected validations" do
        expect { validates }
          .to change { validatable_class.validations }
          .to(attribute => { validator_one => true, validator_two => true })
      end
    end
  end

  describe "#validate" do
    subject(:validate) { validatable.validate }

    around do |spec|
      validatable_class.instance_variable_set(:@validations, validations)
      spec.run
      validatable_class.remove_instance_variable(:@validations)
    end

    let(:attribute_validator) do
      instance_spy(Kangaru::Validation::AttributeValidator)
    end

    before do
      allow(Kangaru::Validation::AttributeValidator)
        .to receive(:new)
        .and_return(attribute_validator)
    end

    context "when no class validations are set", skip: :requires_fix do
      let(:validations) { nil }

      it "does not raise any errors" do
        expect { validate }.not_to raise_error
      end

      it "does not instantiate an attribute validator" do
        validate

        expect(Kangaru::Validation::AttributeValidator)
          .not_to have_received(:new)
      end
    end

    context "when one class validation is set" do
      let(:validations) do
        { attribute => { validator_name => params } }
      end

      let(:attribute) { :some_attribute }

      let(:validator_name) { :validator }

      context "and validation params are not specified" do
        let(:params) { true }

        it "does not raise any errors" do
          expect { validate }.not_to raise_error
        end

        it "instantiates one attribute validator" do
          validate

          expect(Kangaru::Validation::AttributeValidator)
            .to have_received(:new)
            .with(model: validatable, attribute: :some_attribute)
            .once
        end

        it "validates the attribute" do
          validate

          expect(attribute_validator)
            .to have_received(:validate)
            .with(validator_name)
            .once
        end
      end

      context "and validation params are specified" do
        let(:params) { { foo: "foo", bar: "bar" } }

        it "does not raise any errors" do
          expect { validate }.not_to raise_error
        end

        it "instantiates one attribute validator" do
          validate

          expect(Kangaru::Validation::AttributeValidator)
            .to have_received(:new)
            .with(model: validatable, attribute:)
            .once
        end

        it "runs the validator" do
          validate
          expect(attribute_validator)
            .to have_received(:validate)
            .with(validator_name, **params)
            .once
        end
      end
    end

    context "when two class validations are set" do
      context "and validations are for different attributes" do
        let(:validations) do
          {
            attribute_one => {
              validator_one_name => true
            },

            attribute_two => {
              validator_two_name => true
            }
          }
        end

        let(:attribute_one) { :some_attribute }
        let(:attribute_two) { :another_attribute }

        let(:validator_one_name) { :validator_one }
        let(:validator_two_name) { :validator_two }

        it "does not raise any errors" do
          expect { validate }.not_to raise_error
        end

        it "instantiates an attribute validator for the first attribute" do
          validate

          expect(Kangaru::Validation::AttributeValidator)
            .to have_received(:new)
            .with(model: validatable, attribute: attribute_one)
            .once
        end

        it "instantiates an attribute validator for the second attribute" do
          validate

          expect(Kangaru::Validation::AttributeValidator)
            .to have_received(:new)
            .with(model: validatable, attribute: attribute_two)
            .once
        end

        it "runs the first validator" do
          validate

          expect(attribute_validator)
            .to have_received(:validate)
            .with(validator_one_name)
            .once
        end

        it "runs the second validator" do
          validate

          expect(attribute_validator)
            .to have_received(:validate)
            .with(validator_two_name)
            .once
        end
      end

      context "and validations are for the same attribute" do
        let(:validations) do
          {
            attribute => {
              validator_one_name => true,
              validator_two_name => true
            }
          }
        end

        let(:attribute) { :some_attribute }

        let(:validator_one_name) { :validator_one }
        let(:validator_two_name) { :validator_two }

        it "does not raise any errors" do
          expect { validate }.not_to raise_error
        end

        it "instantiates one attribute validator" do
          validate

          expect(Kangaru::Validation::AttributeValidator)
            .to have_received(:new)
            .with(model: validatable, attribute:)
            .once
        end

        it "runs the first validator" do
          validate

          expect(attribute_validator)
            .to have_received(:validate)
            .with(validator_one_name)
            .once
        end

        it "runs the second validator" do
          validate

          expect(attribute_validator)
            .to have_received(:validate)
            .with(validator_two_name)
            .once
        end
      end
    end
  end
end
