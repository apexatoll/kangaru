RSpec.describe Kangaru::Request do
  subject(:request) { described_class.new(**attributes) }

  let(:attributes) { { path:, params: }.compact }

  let(:path) { "/foo/bar/baz" }

  let(:params) { { foo: "foo", bar: "bar" } }

  let(:path_parser) do
    instance_spy(
      Kangaru::PathParser, controller: path_controller, action: path_action
    )
  end

  let(:path_controller) { nil }
  let(:path_action) { nil }

  before do
    allow(Kangaru::PathParser).to receive(:new).and_return(path_parser)
  end

  describe "#initialize" do
    it "sets the attributes" do
      expect(request).to have_attributes(**attributes)
    end
  end

  describe "#controller" do
    subject(:controller) { request.controller }

    context "when no controller is extracted from the path" do
      let(:path_controller) { nil }

      let(:configurator) do
        instance_double(Kangaru::Configurators::RequestConfigurator, **config)
      end

      let(:config) { { default_controller: } }

      before do
        stub_const "CustomController", Class.new

        allow_any_instance_of(described_class)
          .to receive(:config)
          .and_return(configurator)
      end

      context "and custom default controller is not set by config" do
        let(:default_controller) { nil }

        it "returns the default controller name" do
          expect(controller).to eq(described_class::DEFAULT_CONTROLLER)
        end
      end

      context "and custom default controller class is set by config" do
        let(:default_controller) { CustomController }

        it "returns the custom controller name" do
          expect(controller).to eq("CustomController")
        end
      end

      context "and custom default controller name is set by config" do
        let(:default_controller) { "CustomController" }

        it "returns the custom controller name" do
          expect(controller).to eq("CustomController")
        end
      end
    end

    context "when base controller is extracted from the path" do
      let(:path_controller) { "foobar" }

      it "returns the expected controller name" do
        expect(controller).to eq("FoobarController")
      end
    end

    context "when namespaced controller is extracted from the path" do
      let(:path_controller) { "foobar/baz_bar" }

      it "returns the expected controller name" do
        expect(controller).to eq("Foobar::BazBarController")
      end
    end
  end

  describe "#action" do
    subject(:action) { request.action }

    context "when no action is extracted from the path" do
      let(:path_action) { nil }

      it "returns the default action" do
        expect(action).to eq(described_class::DEFAULT_ACTION)
      end
    end

    context "when action is extracted from the path" do
      let(:path_action) { :some_action }

      it "returns the extracted action" do
        expect(action).to eq(path_action)
      end
    end
  end
end
