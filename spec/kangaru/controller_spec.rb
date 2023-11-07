# rubocop:disable RSpec/SubjectStub
RSpec.describe Kangaru::Controller do
  subject(:controller) { described_class.new(request) }

  let(:request) do
    instance_double(
      Kangaru::Request,
      controller: request_controller, action: request_action
    )
  end

  let(:request_controller) { "SomeController" }

  let(:request_action) { :some_action }

  let(:application) { instance_spy(Kangaru::Application, namespace:) }

  let(:namespace) { Namespace }

  before do
    stub_const "Namespace", Module.new

    allow(Kangaru).to receive(:application).and_return(application)
  end

  describe "#execute" do
    subject(:execute) { controller.execute }

    let(:action_view_file) { instance_spy(Pathname) }

    let(:renderer) { instance_spy(Kangaru::Renderer) }

    around do |spec|
      described_class.define_method(request_action) { nil }
      spec.run
      described_class.remove_method(request_action)
    end

    before do
      allow(Kangaru::Renderer)
        .to receive(:new)
        .and_return(renderer)

      allow(application)
        .to receive(:view_path)
        .with(described_class.path, request_action.to_s)
        .and_return(action_view_file)

      allow(controller)
        .to receive(request_action)
        .and_return(method_return)
    end

    shared_examples :executes_command do
      it "sends the command action message to itself" do
        execute
        expect(controller).to have_received(request_action).once
      end
    end

    context "when method returns a falsy value" do
      let(:method_return) { false }

      include_examples :executes_command

      it "does not query the application for the location of the view file" do
        execute

        expect(application)
          .not_to have_received(:view_path)
          .with(described_class.path, request_action.to_s)
      end

      it "does not instantiate a renderer" do
        execute

        expect(Kangaru::Renderer)
          .not_to have_received(:new)
          .with(action_view_file)
      end
    end

    context "when method returns a truthy value" do
      let(:method_return) { true }

      include_examples :executes_command

      it "queries the application for the location of the view file" do
        execute

        expect(application)
          .to have_received(:view_path)
          .with(described_class.path, request_action.to_s)
          .once
      end

      it "instantiates a renderer for the action view file" do
        execute

        expect(Kangaru::Renderer)
          .to have_received(:new)
          .with(action_view_file)
          .once
      end

      it "renders the command output" do
        execute

        expect(renderer)
          .to have_received(:render)
          .with(a_kind_of(Binding))
          .once
      end
    end
  end

  describe ".path" do
    subject(:path) { controller_class.path }

    let(:controller_class) { Class.new(described_class) }

    let(:name) { "#{namespace}::#{controller_name}" }

    before do
      allow(controller_class).to receive(:name).and_return(name)
    end

    context "when controller is in Kangaru namespace" do
      let(:namespace) { "Kangaru" }

      context "and controller is not nested" do
        let(:controller_name) { "BazController" }

        it "returns the expected path" do
          expect(path).to eq("baz")
        end
      end

      context "and controller is nested" do
        let(:controller_name) { "Foobar::BazController" }

        it "returns the expected path" do
          expect(path).to eq("foobar/baz")
        end
      end
    end

    context "when controller is in gem namespace" do
      let(:namespace) { "SomeGem" }

      context "and controller is not nested" do
        let(:controller_name) { "BazController" }

        it "returns the expected path" do
          expect(path).to eq("baz")
        end
      end

      context "and controller is nested" do
        let(:controller_name) { "Foobar::BazController" }

        it "returns the expected path" do
          expect(path).to eq("foobar/baz")
        end
      end
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
