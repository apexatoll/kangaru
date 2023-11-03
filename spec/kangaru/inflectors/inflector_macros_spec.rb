RSpec.describe Kangaru::Inflectors::InflectorMacros do
  subject(:target_class) do
    Class.new { extend Kangaru::Inflectors::InflectorMacros }
  end

  describe "inheriting target classes" do
    subject(:inherited_class) { Class.new(target_class) }

    let(:inflection_params) do
      { input_filter:, token_transformer:, token_joiner:, group_joiner: }
    end

    let(:input_filter)      { :foo }
    let(:token_transformer) { :bar }
    let(:token_joiner)      { :baz }
    let(:group_joiner)      { :far }

    around do |spec|
      inflection_params.each do |attribute, value|
        target_class.instance_variable_set(:"@#{attribute}", value)
      end

      spec.run

      inflection_params.each_key do |attribute|
        target_class.remove_instance_variable(:"@#{attribute}")
      end
    end

    def class_attribute(name)
      inherited_class.instance_variable_get(:"@#{name}")
    end

    it "forwards the input_filter to the child class" do
      expect(class_attribute(:input_filter)).to eq(input_filter)
    end

    it "forwards the token_transformer to the child class" do
      expect(class_attribute(:token_transformer)).to eq(token_transformer)
    end

    it "forwards the token_joiner to the child class" do
      expect(class_attribute(:token_joiner)).to eq(token_joiner)
    end

    it "forwards the group_joiner to the child class" do
      expect(class_attribute(:group_joiner)).to eq(group_joiner)
    end
  end

  describe "#filter_input_with" do
    subject(:filter_input_with) do
      target_class.filter_input_with(pattern)
    end

    let(:pattern) { /./ }

    it "sets the instance variable" do
      expect { filter_input_with }
        .to change { target_class.instance_variable_get(:@input_filter) }
        .from(nil)
        .to(pattern)
    end
  end

  describe "#transform_tokens_with" do
    context "when called with a proc" do
      subject(:transform_tokens_with) do
        target_class.transform_tokens_with(&block)
      end

      let(:block) { ->(token) { token.upcase } }

      it "sets the instance variable" do
        expect { transform_tokens_with }
          .to change { target_class.instance_variable_get(:@token_transformer) }
          .from(nil)
          .to(block)
      end
    end

    context "when called with a symbol" do
      subject(:transform_tokens_with) do
        target_class.transform_tokens_with(symbol)
      end

      let(:symbol) { :method }

      it "sets the instance variable" do
        expect { transform_tokens_with }
          .to change { target_class.instance_variable_get(:@token_transformer) }
          .from(nil)
          .to(symbol)
      end
    end
  end

  describe "#join_tokens_with" do
    subject(:join_tokens_with) do
      target_class.join_tokens_with(joiner)
    end

    let(:joiner) { "." }

    it "sets the instance variable" do
      expect { join_tokens_with }
        .to change { target_class.instance_variable_get(:@token_joiner) }
        .from(nil)
        .to(joiner)
    end
  end

  describe "#join_groups_with" do
    subject(:join_groups_with) do
      target_class.join_groups_with(joiner)
    end

    let(:joiner) { "." }

    it "sets the instance variable" do
      expect { join_groups_with }
        .to change { target_class.instance_variable_get(:@group_joiner) }
        .from(nil)
        .to(joiner)
    end
  end

  describe "#post_process_with" do
    context "when called with a proc" do
      subject(:post_process_with) do
        target_class.post_process_with(&block)
      end

      let(:block) { ->(token) { token.upcase } }

      it "sets the instance variable" do
        expect { post_process_with }
          .to change { target_class.instance_variable_get(:@post_processor) }
          .from(nil)
          .to(block)
      end
    end

    context "when calledd iwth a symbol" do
      subject(:post_process_with) do
        target_class.post_process_with(symbol)
      end

      let(:symbol) { :method }

      it "sets the instance variable" do
        expect { post_process_with }
          .to change { target_class.instance_variable_get(:@post_processor) }
          .from(nil)
          .to(symbol)
      end
    end
  end
end
