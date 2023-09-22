RSpec.describe Kangaru::Router do
  subject(:router) { described_class.new(command, namespace:) }

  let(:command) { instance_double(Kangaru::Command, controller:, action:) }

  let(:controller) { "SomeController" }

  let(:action) { :some_action }

  let(:namespace) { SomeNamespace }

  let(:controller_class) do
    Class.new(described_class) { def some_action = nil }
  end

  before do
    stub_const "SomeNamespace", Module.new
    stub_const "SomeNamespace::SomeController", controller_class
  end

  describe "#initialize" do
    context "when command controller is not defined" do
      let(:controller) { "AnotherController" }

      it "raises an error" do
        expect { router }.to raise_error(
          described_class::UndefinedControllerError,
          "#{controller} is not defined in #{namespace}"
        )
      end
    end

    context "when command controller is defined" do
      let(:controller) { "SomeController" }

      context "and command action is not defined" do
        let(:controller_class) { Class.new(described_class) }

        it "raises an error" do
          expect { router }.to raise_error(
            described_class::UndefinedActionError,
            "#{action} is not defined by #{controller}"
          )
        end
      end

      context "and command action is defined" do
        it "does not raise an error" do
          expect { router }.not_to raise_error
        end

        it "sets the attributes" do
          expect(router).to have_attributes(command:, namespace:)
        end
      end
    end
  end

  describe "#resolve" do
    subject(:resolve) { router.resolve }

    let(:controller_spy) { instance_spy(controller_class) }

    before do
      allow(controller_class).to receive(:new).and_return(controller_spy)
    end

    it "instantiates a controller instance" do
      resolve
      expect(controller_class).to have_received(:new).with(command)
    end

    it "triggers the controller to execute the command" do
      resolve
      expect(controller_spy).to have_received(:execute).once
    end
  end
end
