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

  describe "#validate_all" do
    let(:validate_all) { attribute_validator.validate_all(**validations) }

    before do
      allow(Kangaru::Validators).to receive(:get).and_call_original
    end

    context "when no validations are specified" do
      let(:validations) { {} }

      it "does not raise any errors" do
        expect { validate_all }.not_to raise_error
      end

      it "does not query any validator classes" do
        validate_all
        expect(Kangaru::Validators).not_to have_received(:get)
      end
    end

    context "when one validation is specified" do
      let(:validations) { { validator => params } }

      let(:params) { {} }

      let(:validator_class)    { class_spy(Kangaru::Validator) }
      let(:validator_instance) { instance_spy(validator_class) }

      before do
        stub_const "Kangaru::Validators::FooValidator", validator_class

        allow(Kangaru::Validators::FooValidator)
          .to receive(:new)
          .and_return(validator_instance)
      end

      context "and validator is not defined" do
        let(:validator) { :undefined }

        it "raises an error" do
          expect { validate_all }.to raise_error(
            "UndefinedValidator is not defined"
          )
        end
      end

      context "and validator is defined" do
        let(:validator) { :foo }

        context "and no custom params are specified" do
          let(:params) { true }

          it "does not raise any errors" do
            expect { validate_all }.not_to raise_error
          end

          it "queries the validators namespace for the class" do
            validate_all

            expect(Kangaru::Validators)
              .to have_received(:get)
              .with(validator)
              .once
          end

          it "instantiates a validator without params" do
            validate_all

            expect(Kangaru::Validators::FooValidator)
              .to have_received(:new)
              .with(model:, attribute:)
              .once
          end

          it "runs the validator" do
            validate_all
            expect(validator_instance).to have_received(:validate)
          end
        end

        context "and custom params are specified" do
          let(:params) { { foo: "foo", bar: "bar" } }

          it "does not raise any errors" do
            expect { validate_all }.not_to raise_error
          end

          it "queries the validators namespace for the class" do
            validate_all

            expect(Kangaru::Validators)
              .to have_received(:get)
              .with(validator)
              .once
          end

          it "instantiates a validator with params" do
            validate_all

            expect(Kangaru::Validators::FooValidator)
              .to have_received(:new)
              .with(model:, attribute:, **params)
              .once
          end

          it "runs the validator" do
            validate_all
            expect(validator_instance).to have_received(:validate)
          end
        end
      end
    end

    context "when multiple validations are specified" do
      let(:validations) do
        { validator_one => true, validator_two => true }
      end

      let(:validator_one) { :foo }
      let(:validator_two) { :bar }

      let(:foo_validator_class)    { class_spy(Kangaru::Validator) }
      let(:bar_validator_class)    { class_spy(Kangaru::Validator) }
      let(:foo_validator_instance) { instance_spy(foo_validator_class) }
      let(:bar_validator_instance) { instance_spy(bar_validator_class) }

      before do
        stub_const "Kangaru::Validators::FooValidator", foo_validator_class
        stub_const "Kangaru::Validators::BarValidator", bar_validator_class

        allow(Kangaru::Validators::FooValidator)
          .to receive(:new)
          .and_return(foo_validator_instance)

        allow(Kangaru::Validators::BarValidator)
          .to receive(:new)
          .and_return(bar_validator_instance)
      end

      it "does not raise any errors" do
        expect { validate_all }.not_to raise_error
      end

      it "queries the validators namespace for each class" do
        validate_all

        validations.each_key do |validator_name|
          expect(Kangaru::Validators)
            .to have_received(:get)
            .with(validator_name)
            .once
        end
      end

      it "instantiates the foo validator" do
        validate_all

        expect(Kangaru::Validators::FooValidator)
          .to have_received(:new)
          .with(model:, attribute:)
          .once
      end

      it "runs the foo validator" do
        validate_all
        expect(foo_validator_instance).to have_received(:validate)
      end

      it "instantiates the bar validator" do
        validate_all

        expect(Kangaru::Validators::BarValidator)
          .to have_received(:new)
          .with(model:, attribute:)
          .once
      end

      it "runs the bar validator" do
        validate_all
        expect(bar_validator_instance).to have_received(:validate)
      end
    end
  end
end
