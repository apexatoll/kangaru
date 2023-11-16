RSpec.describe Kangaru::Validators do
  describe ".get", :stub_application do
    subject(:validator) { described_class.get(name) }

    let(:validator_class) do
      Class.new(Kangaru::Validator)
    end

    let(:name) { "example" }

    shared_examples :raises_error do
      it "raises an error" do
        expect { validator }.to raise_error(
          "ExampleValidator is not defined"
        )
      end
    end

    shared_examples :returns_validator_class do
      it "does not raise any errors" do
        expect { validator }.not_to raise_error
      end

      it "returns the validator class" do
        expect(validator).to eq(validator_class)
      end
    end

    context "when application is not set" do
      let(:application) { nil }

      context "and validator is not defined by Kangaru" do
        include_examples :raises_error
      end

      context "and validator is defined by Kangaru" do
        before do
          stub_const "#{described_class}::ExampleValidator", validator_class
        end

        include_examples :returns_validator_class
      end
    end

    context "when application is set" do
      let(:application) { instance_double(Kangaru::Application, namespace:) }

      let(:validators_namespace) { nil }

      before do
        allow(application)
          .to receive(:const_get)
          .with(:Validators)
          .and_return(validators_namespace)
      end

      context "and validator is not defined by Kangaru" do
        context "and validators namespace is not defined by application" do
          let(:validators_namespace) { nil }

          include_examples :raises_error
        end

        context "and validators namespace is defined by application" do
          let(:validators_namespace) { Module.new }

          before do
            allow(application)
              .to receive(:const_get)
              .with(:Validators)
              .and_return(validators_namespace)

            stub_const "#{namespace}::Validators", validators_namespace
          end

          context "and validator class is not defined" do
            include_examples :raises_error
          end

          context "and validator class is defined" do
            before do
              stub_const "#{validators_namespace}::ExampleValidator",
                         validator_class
            end

            include_examples :returns_validator_class
          end
        end
      end
    end
  end
end
