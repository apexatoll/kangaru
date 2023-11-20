RSpec.describe Kangaru::Validatable do
  subject(:validatable) { validatable_class.new }

  let(:validatable_class) do
    Class.new { include Kangaru::Validatable }
  end

  describe ".validates" do
    subject(:validates) do
      validatable_class.validates(attribute, **validations)
    end

    after do
      validatable_class.remove_instance_variable(:@validation_rules)
    end

    let(:attribute) { :some_attribute }

    context "when one validation rule is specified" do
      let(:validations) { { validator_name => params } }

      let(:validator_name) { :some_validator }

      context "and validation params are not specified" do
        let(:params) { true }

        it "sets the expected validations" do
          expect { validates }
            .to change { validatable_class.validation_rules }
            .to(attribute => { validator_name => true })
        end
      end

      context "and validation params are specified" do
        let(:params) { { foo: "foo" } }

        it "sets the expected validations" do
          expect { validates }
            .to change { validatable_class.validation_rules }
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
          .to change { validatable_class.validation_rules }
          .to(attribute => { validator_one => true, validator_two => true })
      end
    end
  end

  describe "#validate" do
    subject(:validate) { validatable.validate }

    let(:model_validator) { instance_spy(Kangaru::Validation::ModelValidator) }

    let(:rules) { { foo: "foo", bar: "bar" } }

    around do |spec|
      validatable_class.instance_variable_set(:@validation_rules, rules)
      spec.run
      validatable_class.remove_instance_variable(:@validation_rules)
    end

    before do
      allow(Kangaru::Validation::ModelValidator)
        .to receive(:new)
        .and_return(model_validator)
    end

    it "instantiates a ModelValidator" do
      validate

      expect(Kangaru::Validation::ModelValidator)
        .to have_received(:new)
        .with(model: validatable)
        .once
    end

    it "runs the model validator" do
      validate
      expect(model_validator).to have_received(:validate!).with(**rules).once
    end
  end
end
