RSpec.describe Kangaru::Application do
  subject(:application) { described_class.new(name:, dir:, namespace:) }

  let(:name) { "some_app" }

  let(:dir) { "/foo/bar" }

  let(:namespace) { SomeApp }

  let(:loader) { instance_spy(Zeitwerk::Loader) }

  let(:gem_inflector) { instance_spy(Zeitwerk::GemInflector) }

  before do
    stub_const "SomeApp", Module.new

    allow(Zeitwerk::Loader).to receive(:new).and_return(loader)
    allow(Zeitwerk::GemInflector).to receive(:new).and_return(gem_inflector)
  end

  describe "#initialize" do
    it "instantiates a Zeitwerk loader" do
      application
      expect(Zeitwerk::Loader).to have_received(:new).once
    end

    it "instantiates a Zeitwerk gem inflector for the root file" do
      application

      expect(Zeitwerk::GemInflector)
        .to have_received(:new)
        .with("/foo/bar/some_app/lib/some_app.rb")
        .once
    end

    it "configures the loader to use the instantiated gem inflector" do
      application
      expect(loader).to have_received(:inflector=).with(gem_inflector).once
    end

    it "configures the loader to load the lib dir" do
      application

      expect(loader)
        .to have_received(:push_dir)
        .with("/foo/bar/some_app/lib")
        .once
    end

    it "enables the instantiated loader" do
      application
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

  describe "#config" do
    subject(:config) { application.config }

    it "returns a config object" do
      expect(config).to be_a(Kangaru::Config)
    end

    it "caches the config object" do
      expect { config }
        .to change { application.instance_variable_defined?(:@config) }
        .from(false)
        .to(true)
    end
  end

  describe ".from_callsite" do
    subject(:application) do
      described_class.from_callsite(callsite, namespace:)
    end

    context "when root file is not in a gem structure" do
      let(:callsite) { "/foobar/some_dir/some_file.rb" }

      it "is an application" do
        expect(application).to be_a(described_class)
      end

      it "sets the expected_attributes" do
        expect(application).to have_attributes(
          name: "some_file", dir: "/foobar/some_dir", namespace:
        )
      end
    end

    context "when root file is in a gem structure" do
      let(:callsite) { "/foobar/some_gem/lib/some_gem.rb" }

      it "is an application" do
        expect(application).to be_a(described_class)
      end

      it "sets the expected_attributes" do
        expect(application).to have_attributes(
          name: "some_gem", dir: "/foobar", namespace:
        )
      end
    end
  end
end
