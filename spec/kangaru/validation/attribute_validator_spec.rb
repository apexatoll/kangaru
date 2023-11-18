RSpec.describe Kangaru::Validation::AttributeValidator do
  subject(:attribute_validator) { described_class.new(model:, attribute:) }

  let(:model) { SomeModel.new(some_attribute: model_value) }

  let(:attribute) { :some_attribute }

  let(:model_class) do
    Class.new do
      attr_accessor :some_attribute

      def initialize(some_attribute:)
        @some_attribute = some_attribute
      end
    end
  end

  let(:model_value) { :some_value }

  before { stub_const "SomeModel", model_class }

  describe "#validate" do
    subject(:validate) { attribute_validator.validate(validator, **params) }

    let(:validator) { :foobar }
    let(:params) { {} }

    shared_context :validator_defined do
      before do
        stub_const "Kangaru::Validators::FoobarValidator", validator_class

        allow(Kangaru::Validators::FoobarValidator)
          .to receive(:new)
          .and_return(validator_instance)
      end

      let(:validator_instance) { instance_spy(validator_class) }

      let(:validator_class) do
        Class.new(Kangaru::Validator)
      end
    end

    context "when inferred validator is not defined in validators namespace" do
      it "raises an error" do
        expect { validate }.to raise_error("FoobarValidator is not defined")
      end
    end

    context "when inferred validator is defined in validators namespace" do
      include_context :validator_defined

      it "instantiates the inferred validator" do
        validate

        expect(Kangaru::Validators::FoobarValidator)
          .to have_received(:new)
          .with(model:, attribute:, params:)
      end

      it "runs the validator" do
        validate
        expect(validator_instance).to have_received(:validate).once
      end
    end
  end
end
