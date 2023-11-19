RSpec.describe "a validatable model using custom validator rules" do
  subject(:model) { SomeGem::Model.new(**attributes) }

  include_context :kangaru_initialised

  let(:attributes) { { attribute: value } }

  let(:value) { :valid }

  let(:model_class) do
    <<~RUBY
      module SomeGem
        class Model
          include Kangaru::Validatable

          #{validations}

          attr_reader :attribute

          def initialize(attribute:)
            @attribute = attribute
          end
        end
      end
    RUBY
  end

  let(:validator_class) do
    <<~RUBY
      module SomeGem
        module Validators
          class CustomValidator < Kangaru::Validator
            def validate
              return if value == :valid

              add_error!("is invalid")
            end
          end
        end
      end
    RUBY
  end

  before do
    gem.path("validators", ext: nil).mkdir
    gem.path("validators", "custom_validator").write(validator_class)

    gem.path("model").write(model_class)

    gem.load!
  end

  describe "#validate" do
    subject(:validate) { model.validate }

    let(:validations) do
      <<~RUBY
        validates :attribute, #{validator_name}: true
      RUBY
    end

    context "when validator with given name is not defined" do
      let(:validator_name) { :undefined }

      it "raises an error" do
        expect { validate }.to raise_error("UndefinedValidator is not defined")
      end
    end

    context "when validator with given name is defined" do
      let(:validator_name) { :custom }

      context "and model is not valid" do
        let(:value) { :invalid }

        it "does not raise any errors" do
          expect { validate }.not_to raise_error
        end

        it "is not valid" do
          expect(model).not_to be_valid
        end

        it "adds an error" do
          expect { validate }.to change { model.errors.count }.by(1)
        end

        it "sets the expected message" do
          validate
          expect(model.errors.last.full_message).to eq("Attribute is invalid")
        end
      end

      context "and model is valid" do
        let(:value) { :valid }

        it "does not raise any errors" do
          expect { validate }.not_to raise_error
        end

        it "is valid" do
          expect(model).to be_valid
        end

        it "does not add any errors" do
          expect { validate }.not_to change { model.errors }
        end
      end
    end
  end
end
