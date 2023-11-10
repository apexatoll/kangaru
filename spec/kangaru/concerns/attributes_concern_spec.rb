RSpec.describe Kangaru::Concerns::AttributesConcern do
  subject(:model) { model_class.new(**attributes) }

  let(:model_class) do
    Class.new { include Kangaru::Concerns::AttributesConcern }
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

  describe ".set_default" do
    subject(:set_default) { model_class.set_default(**attributes) }

    let(:attributes) { { bar: "bar", baz: "baz" } }

    it "sets the default attributes" do
      expect { set_default }
        .to change { model_class.defaults }
        .to(include(**attributes))
    end
  end

  describe "#initialize" do
    before do
      allow(model_class).to receive(:defaults).and_return(defaults)
    end

    context "when target class has not defined any attr_accessors" do
      context "and defaults are not set" do
        let(:defaults) { {} }

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

      context "and defaults are set" do
        let(:defaults) { { foo: "foo" } }

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
    end

    context "when target class has defined attr_accessors" do
      let(:model_class) do
        Class.new do
          include Kangaru::Concerns::AttributesConcern

          attr_accessor :foo, :bar, :baz
        end
      end

      context "and defaults are not set" do
        let(:defaults) { {} }

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

      context "and defaults are set" do
        let(:defaults) { { foo: "foobar" } }

        context "and no attributes are given" do
          let(:attributes) { {} }

          it "does not raise any errors" do
            expect { model }.not_to raise_error
          end

          it "sets the default attributes" do
            expect(model).to have_attributes(**defaults)
          end
        end

        context "and attributes are given" do
          let(:attributes) { { foo: "foo", bar: "bar" } }

          it "does not raise any errors" do
            expect { model }.not_to raise_error
          end

          it "sets the attributes ensuring that defaults are overrideable" do
            expect(model).to have_attributes(**attributes)
          end
        end
      end
    end
  end
end
