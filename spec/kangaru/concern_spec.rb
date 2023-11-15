RSpec.describe Kangaru::Concern do
  subject(:model_class) do
    Class.new { include Concern }
  end

  describe ".included" do
    subject(:include_concern) { model_class.include(concern) }

    let(:model_class) do
      Class.new do
        def self.some_static_method = nil
      end
    end

    let(:concern) do
      Module.new do
        extend Kangaru::Concern

        included do
          some_static_method

          @some_variable = true
        end
      end
    end

    before do
      allow(model_class).to receive(:some_static_method)
    end

    after do
      model_class.remove_instance_variable(:@some_variable)
    end

    it "runs the block" do
      include_concern
      expect(model_class).to have_received(:some_static_method).once
    end

    it "is scoped to the model class" do
      expect { include_concern }
        .to change { model_class.instance_variable_get(:@some_variable) }
        .from(nil)
        .to(true)
    end
  end

  describe ".class_methods" do
    let(:concern) do
      Module.new do
        extend Kangaru::Concern

        class_methods do
          attr_reader :some_ivar

          def some_method = nil
        end
      end
    end

    let(:concern_ivar) { :concern_ivar }

    let(:model_class_ivar) { :model_class_ivar }

    before do
      stub_const "Concern", concern
      stub_const "Model", model_class

      Concern.instance_variable_set(:@some_ivar, concern_ivar)
      Model.instance_variable_set(:@some_ivar, model_class_ivar)
    end

    it "sets the class methods" do
      expect(Model).to respond_to(:some_method, :some_ivar)
    end

    it "scopes instance variables to the model class" do
      expect(Model.some_ivar).to eq(model_class_ivar)
    end
  end
end
