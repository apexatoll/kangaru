# rubocop:disable RSpec/SubjectStub

RSpec.describe Kangaru::Controller do
  subject(:controller) { described_class.new(command) }

  let(:command) { instance_double(Kangaru::Command, action:) }

  let(:action) { :some_action }

  describe "#initialize" do
    it "sets the command" do
      expect(controller.command).to eq(command)
    end
  end

  describe "#execute" do
    subject(:execute) { controller.execute }

    around do |spec|
      described_class.define_method(action) { nil }
      spec.run
      described_class.remove_method(action)
    end

    before do
      allow(controller).to receive(action)
    end

    it "sends the command action message to itself" do
      execute
      expect(controller).to have_received(action).once
    end
  end
end

# rubocop:enable RSpec/SubjectStub
