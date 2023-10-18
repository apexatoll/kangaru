RSpec.describe Kangaru::Application do
  subject(:application) { described_class.new(source:, namespace:) }

  let(:source) { "/foo/bar/some_app/lib/some_app.rb" }

  let(:namespace) { SomeApp }

  let(:loader) { instance_spy(Zeitwerk::Loader) }

  let(:gem_inflector) { instance_spy(Zeitwerk::GemInflector) }

  before do
    stub_const "SomeApp", Module.new

    allow(Zeitwerk::Loader).to receive(:new).and_return(loader)
    allow(Zeitwerk::GemInflector).to receive(:new).and_return(gem_inflector)
  end

  describe "#initialize" do
    let(:expected_collapsed_dirs) do
      %w[
        /foo/bar/some_app/lib/some_app/models
        /foo/bar/some_app/lib/some_app/controllers
      ]
    end

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

    it "collapses the models and controller directories" do
      application

      expect(loader).to have_received(:collapse).with(
        expected_collapsed_dirs
      ).once
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

    it "initialises the config" do
      expect(application.config).to be_a(Kangaru::Config)
    end
  end

  describe "#configure" do
    subject(:configure) { application.configure(&configure_block) }

    let(:configure_block) { proc {} }

    before do
      allow(application.config).to receive(:import_external_config!)
    end

    describe "database setup" do
      before do
        allow(Kangaru::Database).to receive(:new).and_return(database)
      end

      let(:database) { instance_spy(Kangaru::Database, setup!: nil) }

      context "when no configuration is set" do
        let(:configure_block) { proc {} }

        it "does not create a database" do
          configure
          expect(Kangaru::Database).not_to have_received(:new)
        end

        it "does not set the application database instance" do
          expect { configure }.not_to change { application.database }.from(nil)
        end
      end

      context "when configuration sets a database adaptor" do
        let(:configure_block) do
          ->(config) { config.database.adaptor = :sqlite }
        end

        it "creates a database" do
          configure
          expect(Kangaru::Database).to have_received(:new).once
        end

        it "sets up the database" do
          configure
          expect(database).to have_received(:setup!).once
        end

        it "migrates the database" do
          configure
          expect(database).to have_received(:migrate!).once
        end

        it "sets the application database instance" do
          expect { configure }
            .to change { application.database }
            .from(nil)
            .to(database)
        end
      end
    end

    it "imports external config" do
      configure
      expect(application.config).to have_received(:import_external_config!).once
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
