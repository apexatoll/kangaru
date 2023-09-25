# rubocop:disable RSpec/SubjectStub

RSpec.describe Kangaru::Controller do
  subject(:controller) { described_class.new(command) }

  let(:command) { instance_double(Kangaru::Command, action:) }

  let(:action) { :some_action }

  let(:renderer) { instance_spy(Kangaru::Renderer) }

  before do
    allow(Kangaru::Renderer).to receive(:new).and_return(renderer)
  end

  describe "#initialize" do
    it "sets the command" do
      expect(controller.command).to eq(command)
    end

    it "instantiates a renderer" do
      controller
      expect(Kangaru::Renderer).to have_received(:new).with(command).once
    end

    it "sets the renderer" do
      expect(controller.renderer).to eq(renderer)
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

    it "renders the command output" do
      execute
      expect(renderer).to have_received(:render).with(a_kind_of(Binding)).once
    end
  end
end

# rubocop:enable RSpec/SubjectStub
