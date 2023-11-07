RSpec.describe Kangaru::Router do
  subject(:router) { described_class.new(request, namespace:) }

  let(:namespace) { SomeNamespace }

  before { stub_const "SomeNamespace", Module.new }

  describe "#resolve" do
    subject(:resolve) { router.resolve }

    let(:request) do
      instance_double(Kangaru::Request, controller:, action:)
    end

    let(:controller) { "SomeController" }

    let(:action) { :some_action }

    let(:controller_spy) { instance_spy(controller_class) }

    let(:controller_class) do
      Class.new(Kangaru::Controller) { def some_action = nil }
    end

    before do
      allow(controller_class).to receive(:new).and_return(controller_spy)
    end

    context "when request controller is not defined" do
      it "raises an error" do
        expect { resolve }.to raise_error(
          "#{controller} is not defined in #{namespace}"
        )
      end
    end

    context "when request controller is defined" do
      before { stub_const "#{namespace}::#{controller}", controller_class }

      context "and command action is not defined" do
        let(:controller_class) { Class.new(Kangaru::Controller) }

        it "raises an error" do
          expect { resolve }.to raise_error(
            "#{action} is not defined by #{controller}"
          )
        end
      end

      context "and command action is defined" do
        it "does not raise an error" do
          expect { resolve }.not_to raise_error
        end

        it "instantiates a controller instance" do
          resolve
          expect(controller_class).to have_received(:new).with(request)
        end

        it "triggers the controller to execute the command" do
          resolve
          expect(controller_spy).to have_received(:execute).once
        end
      end
    end
  end
end
