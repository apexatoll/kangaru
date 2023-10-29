# rubocop:disable RSpec/SubjectStub

RSpec.describe Kangaru::Controller do
  subject(:controller) { described_class.new(command) }

  let(:command) do
    instance_double(
      Kangaru::LegacyCommand, controller: controller_name, action:
    )
  end

  let(:controller_name) { :some_controller }

  let(:action) { :some_action }

  let(:application) do
    instance_spy(Kangaru::Application, namespace:, view_path:)
  end

  let(:namespace) { Namespace }

  let(:view_path) { instance_spy(Pathname) }

  let(:renderer) { instance_spy(Kangaru::Renderer) }

  before do
    stub_const "Namespace", Module.new

    allow(Kangaru).to receive(:application).and_return(application)
    allow(Kangaru::Renderer).to receive(:new).and_return(renderer)
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

    it "instantiates a renderer" do
      execute
      expect(Kangaru::Renderer).to have_received(:new).with(view_path).once
    end

    it "renders the command output" do
      execute
      expect(renderer).to have_received(:render).with(a_kind_of(Binding)).once
    end
  end

  describe ".const_missing" do
    subject(:lookup_const) { described_class::Foobar }

    let(:foobar) { Module.new }

    context "when specified const is not defined inside Controller" do
      context "and const not defined in application namespace" do
        it "raises an error" do
          expect { lookup_const }.to raise_error(NameError)
        end
      end

      context "and const defined in application namespace" do
        before { stub_const "Namespace::Foobar", foobar }

        it "does not raise any errors" do
          expect { lookup_const }.not_to raise_error
        end

        it "delegates the const lookup to the application namespace" do
          expect(lookup_const).to eq(foobar)
        end
      end
    end

    context "when specified const is defined inside Controller" do
      before { stub_const "#{described_class}::Foobar", foobar }

      it "does not raise any errors" do
        expect { lookup_const }.not_to raise_error
      end

      it "delegates the const lookup to the application namespace" do
        expect(lookup_const).to eq(foobar)
      end
    end
  end
end

# rubocop:enable RSpec/SubjectStub
