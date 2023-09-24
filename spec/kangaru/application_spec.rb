RSpec.describe Kangaru::Application do
  subject(:application) { described_class.new(name:, dir:, namespace:) }

  let(:name) { "some_app" }

  let(:dir) { "/foo/bar" }

  let(:namespace) { SomeApp }

  before { stub_const "SomeApp", Module.new }

  describe "#setup" do
    subject(:setup) { application.setup }

    before do
      allow(Zeitwerk::Loader).to receive(:new).and_return(loader)
      allow(Zeitwerk::GemInflector).to receive(:new).and_return(gem_inflector)
    end

    let(:loader) { instance_spy(Zeitwerk::Loader) }

    let(:gem_inflector) { instance_spy(Zeitwerk::GemInflector) }

    it "instantiates a Zeitwerk loader" do
      setup
      expect(Zeitwerk::Loader).to have_received(:new).once
    end

    it "instantiates a Zeitwerk gem inflector for the root file" do
      setup

      expect(Zeitwerk::GemInflector)
        .to have_received(:new)
        .with("/foo/bar/some_app/lib/some_app.rb")
        .once
    end

    it "configures the loader to use the instantiated gem inflector" do
      setup
      expect(loader).to have_received(:inflector=).with(gem_inflector).once
    end

    it "configures the loader to load the lib dir" do
      setup

      expect(loader)
        .to have_received(:push_dir)
        .with("/foo/bar/some_app/lib")
        .once
    end

    it "enables the instantiated loader" do
      setup
      expect(loader).to have_received(:setup).once
    end
  end

  describe "#run!" do
    subject(:run!) { application.run!(argv) }

    let(:argv) { %w[foo bar baz] }

    let(:command) { instance_spy(Kangaru::Command) }

    let(:router) { instance_spy(Kangaru::Router) }

    before do
      allow(Kangaru::Command).to receive(:parse).and_return(command)
      allow(Kangaru::Router).to receive(:new).and_return(router)
    end

    it "parses the arguments into a command" do
      run!
      expect(Kangaru::Command).to have_received(:parse).with(argv)
    end

    it "instantiates a router" do
      run!
      expect(Kangaru::Router).to have_received(:new).with(command, namespace:)
    end

    it "resolves the request" do
      run!
      expect(router).to have_received(:resolve)
    end
  end
end
