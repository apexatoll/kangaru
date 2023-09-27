RSpec.describe Kangaru::Concerns::AttributesConcern do
  subject(:model) { model_class.new(**attributes) }

  let(:model_class) do
    Class.new { include Kangaru::Concerns::AttributesConcern }
  end

  describe "#initialize" do
    context "when concern has not defined any attr_accessors" do
      context "and no attributes are given" do
        let(:attributes) { {} }

        it "does not raise any errors" do
          expect { model }.not_to raise_error
        end

        it "does not set any instance variables" do
          expect { model }.not_to change { model_class.instance_variables }
        end
      end

      context "and attributes are given" do
        let(:attributes) { { foo: "foo", bar: "bar" } }

        it "does not raise any errors" do
          expect { model }.not_to raise_error
        end

        it "does not set the attributes" do
          expect(model).not_to respond_to(*attributes.keys)
        end
      end
    end

    context "when concern has defined attr_accessors" do
      let(:model_class) do
        Class.new do
          include Kangaru::Concerns::AttributesConcern

          attr_accessor :foo, :bar, :baz
        end
      end

      context "and no attributes are given" do
        let(:attributes) { {} }

        it "does not raise any errors" do
          expect { model }.not_to raise_error
        end
      end

      context "and attributes are given" do
        let(:attributes) { { foo: "foo", bar: "bar" } }

        it "does not raise any errors" do
          expect { model }.not_to raise_error
        end

        it "sets the attributes" do
          expect(model).to have_attributes(**attributes)
        end
      end
    end
  end

  describe ".attributes" do
    subject(:attributes) { model_class.attributes }

    context "when no attr_accessors are set" do
      it "does not raise any errors" do
        expect { attributes }.not_to raise_error
      end

      it "returns an empty array" do
        expect(attributes).to be_empty
      end
    end

    context "when attr_accessors are set" do
      let(:model_class) do
        Class.new do
          include Kangaru::Concerns::AttributesConcern

          attr_accessor :foo, :bar, :baz
        end
      end

      it "does not raise any errors" do
        expect { attributes }.not_to raise_error
      end

      it "returns the expected attributes" do
        expect(attributes).to contain_exactly(:foo, :bar, :baz)
      end
    end
  end
end