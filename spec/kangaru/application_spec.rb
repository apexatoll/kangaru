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

    context "when no configuration is set" do
      let(:configure_block) { proc {} }

      it "does not raise any errors" do
        expect { configure }.not_to raise_error
      end

      it "does not change the config values" do
        expect { configure }.not_to change { application.config.serialise }
      end
    end

    context "when configuration sets a database adaptor" do
      let(:configure_block) do
        ->(config) { config.database.adaptor = adaptor }
      end

      let(:adaptor) { :sqlite }

      it "does not raise any errors" do
        expect { configure }.not_to raise_error
      end

      it "changes the config values" do
        expect { configure }.to change { application.config.serialise }
      end

      it "sets the expected config value" do
        expect { configure }
          .to change { application.config.database.adaptor }
          .from(nil)
          .to(adaptor)
      end
    end
  end

  describe "#apply_config!" do
    subject(:apply_config!) { application.apply_config! }

    let(:database) { instance_spy(Kangaru::Database) }

    let(:config_valid?) { true }
    let(:config_errors) { [] }

    before do
      allow(Kangaru::Database).to receive(:new).and_return(database)

      allow(application.config).to receive_messages(
        import!: nil, valid?: config_valid?, errors: config_errors
      )
    end

    shared_examples :configures_application do
      it "does not raise any errors" do
        expect { apply_config! }.not_to raise_error
      end

      it "marks the application as configured" do
        expect { apply_config! }
          .to change { application.configured? }
          .from(false)
          .to(true)
      end
    end

    shared_examples :does_not_set_up_database do
      it "does not create a database" do
        apply_config!
        expect(Kangaru::Database).not_to have_received(:new)
      end

      it "does not set the application database instance" do
        expect { apply_config! }
          .not_to change { application.database }
          .from(nil)
      end
    end

    shared_examples :sets_up_database do
      it "creates a database" do
        apply_config!
        expect(Kangaru::Database).to have_received(:new).once
      end

      it "sets up the database" do
        apply_config!
        expect(database).to have_received(:setup!).once
      end

      it "migrates the database" do
        apply_config!
        expect(database).to have_received(:migrate!).once
      end

      it "sets the application database instance" do
        expect { apply_config! }
          .to change { application.database }
          .from(nil)
          .to(database)
      end
    end

    shared_examples :does_not_import_external_config do
      it "does not import external config" do
        apply_config!
        expect(application.config).not_to have_received(:import!)
      end
    end

    shared_examples :imports_external_config do
      it "imports external config" do
        apply_config!
        expect(application.config).to have_received(:import!).once
      end
    end

    context "when config has already been applied" do
      before { application.instance_variable_set(:@configured, true) }

      it "raises an error" do
        expect { apply_config! }.to raise_error("config already applied")
      end
    end

    context "when config has not already been applied" do
      context "and config is invalid" do
        let(:config_valid?) { false }

        let(:config_errors) do
          [Kangaru::Validation::Error.new(attribute:, message:)]
        end

        let(:attribute) { :some_attribute }
        let(:message)   { "can't be blank" }

        it "raises an error" do
          expect { apply_config! }.to raise_error(
            described_class::InvalidConfigError,
            "Some attribute can't be blank"
          )
        end
      end

      context "and config is valid" do
        let(:valid?) { true }
        let(:errors) { [] }

        before do
          application.config_path = config_path
          application.config.database.adaptor = adaptor
        end

        context "and config path is not set" do
          let(:config_path) { nil }

          context "and database adaptor is not set" do
            let(:adaptor) { nil }

            include_examples :configures_application
            include_examples :does_not_set_up_database
            include_examples :does_not_import_external_config
          end

          context "and database adaptor is set" do
            let(:adaptor) { :sqlite }

            include_examples :configures_application
            include_examples :sets_up_database
            include_examples :does_not_import_external_config
          end
        end

        context "and config path is set" do
          let(:config_path) { "/foo/bar/config.yml" }

          context "and database adaptor is not set" do
            let(:adaptor) { nil }

            include_examples :configures_application
            include_examples :does_not_set_up_database
            include_examples :imports_external_config
          end

          context "and database adaptor is set" do
            let(:adaptor) { :sqlite }

            include_examples :configures_application
            include_examples :sets_up_database
            include_examples :imports_external_config
          end
        end
      end
    end
  end

  describe "#run!" do
    subject(:run!) { application.run!(*argv) }

    let(:argv) { %w[foo bar baz] }

    let(:request) { instance_spy(Kangaru::Request) }

    let(:request_builder) do
      instance_spy(Kangaru::RequestBuilder, build: request)
    end

    let(:router) { instance_spy(Kangaru::Router) }

    before do
      allow(Kangaru::RequestBuilder)
        .to receive(:new)
        .and_return(request_builder)

      allow(Kangaru::Router)
        .to receive(:new)
        .and_return(router)
    end

    it "instantiates a request builder" do
      run!
      expect(Kangaru::RequestBuilder).to have_received(:new).with(argv)
    end

    it "builds the request" do
      run!
      expect(request_builder).to have_received(:build).once
    end

    it "instantiates a router" do
      run!
      expect(Kangaru::Router).to have_received(:new).with(namespace:).once
    end

    it "resolves the request" do
      run!
      expect(router).to have_received(:resolve)
    end
  end

  describe "#const_set" do
    subject(:constant) { application.const_get(const_name) }

    let(:const_name) { "Foobar" }

    context "when constant is not defined in application namespace" do
      it "does not raise any errors" do
        expect { constant }.not_to raise_error
      end

      it "returns nil" do
        expect(constant).to be_nil
      end
    end

    context "when constant is defined in application namespace" do
      before do
        stub_const "#{namespace}::#{const_name}", application_constant
      end

      let(:application_constant) { Class.new }

      it "does not raise any errors" do
        expect { constant }.not_to raise_error
      end

      it "returns the application constant" do
        expect(constant).to eq(application_constant)
      end
    end
  end
end
