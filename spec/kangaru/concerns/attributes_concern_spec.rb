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

  describe "#merge!" do
    subject(:merge!) { model.merge!(**new_attributes) }

    let(:attributes) { {} }

    shared_examples :does_not_set_attributes do
      it "does not raise any errors" do
        expect { merge! }.not_to raise_error
      end

      it "does not update the attributes" do
        expect { merge! }.not_to change { model.instance_variables }
      end
    end

    context "when target class has not defined any attr_accessors" do
      let(:model_class) do
        Class.new { include Kangaru::Concerns::AttributesConcern }
      end

      context "and no new attributes are specified" do
        let(:new_attributes) { {} }

        include_examples :does_not_set_attributes
      end

      context "and new attributes are specified" do
        let(:new_attributes) { { foo: "foo", bar: "bar" } }

        include_examples :does_not_set_attributes
      end
    end

    context "when target class has defined attr_accessors" do
      let(:model_class) do
        Class.new do
          include Kangaru::Concerns::AttributesConcern

          attr_accessor :foo, :bar, :baz
        end
      end

      context "and no new attributes are specified" do
        let(:new_attributes) { {} }

        include_examples :does_not_set_attributes
      end

      context "and new attributes are specified" do
        context "and no attributes are valid" do
          let(:new_attributes) { { foobar: "hello", foobaz: "world" } }

          include_examples :does_not_set_attributes
        end

        context "and some attributes are valid" do
          let(:new_attributes) { { foo: "foo", hello: "world" } }

          it "does not raise any errors" do
            expect { merge! }.not_to raise_error
          end

          it "changes the valid attributes" do
            expect { merge! }
              .to change { model.instance_variables }
              .from(be_empty)
              .to(contain_exactly(:@foo))
          end

          it "sets the valid attribute values" do
            expect { merge! }
              .to change { model.foo }
              .from(nil)
              .to(new_attributes[:foo])
          end
        end

        context "and all attributes are valid" do
          let(:new_attributes) { { foo: "foo", bar: "bar", baz: "baz" } }

          it "does not raise any errors" do
            expect { merge! }.not_to raise_error
          end

          it "changes all the attributes" do
            expect { merge! }
              .to change { model.instance_variables }
              .from(be_empty)
              .to(contain_exactly(:@foo, :@bar, :@baz))
          end

          it "sets the valid attribute values" do
            merge!
            expect(model).to have_attributes(**new_attributes)
          end
        end
      end
    end
  end
end
