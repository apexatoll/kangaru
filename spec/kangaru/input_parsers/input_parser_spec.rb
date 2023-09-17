RSpec.describe Kangaru::InputParsers::InputParser do
  subject(:input_parser) { described_class.new(tokens) }

  let(:tokens) { %w[foo bar baz] }

  describe "#parse" do
    subject(:parse) { input_parser.parse }

    it "raises a not implemented error (abstract method)" do
      expect { parse }.to raise_error(NotImplementedError)
    end
  end
end
