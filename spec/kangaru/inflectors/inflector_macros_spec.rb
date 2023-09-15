RSpec.describe Kangaru::Inflectors::InflectorMacros do
  subject(:target_class) do
    Class.new { extend Kangaru::Inflectors::InflectorMacros }
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

    context "when calledd iwth a symbol" do
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
end
