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

    let(:renderer) { instance_spy(Kangaru::Renderer) }

    around do |spec|
      described_class.define_method(request_action) { nil }
      spec.run
      described_class.remove_method(request_action)
    end

    before do
      allow(Kangaru::Renderer).to receive(:new).and_return(renderer)

      allow(controller).to receive(request_action)
    end

    it "sends the command action message to itself" do
      execute
      expect(controller).to have_received(request_action).once
    end

    it "instantiates a renderer" do
      execute

      expect(Kangaru::Renderer)
        .to have_received(:new)
        .with(controller.view_file)
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

  describe "#view_file" do
    subject(:view_file) { controller.view_file }

    it "delegates to the application" do
      view_file

      expect(application)
        .to have_received(:view_path)
        .with(described_class.path, request_action.to_s)
        .once
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
