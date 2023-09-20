RSpec.describe Kangaru::Controller do
  subject(:controller) { described_class.new(command) }

  let(:command) { instance_double(Kangaru::Command) }

  describe "#initialize" do
    it "sets the command" do
      expect(controller.command).to eq(command)
    end
  end
end
