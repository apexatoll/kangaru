RSpec.describe Kangaru::Interface, :stub_application do
  subject(:target) { Module.new { extend Kangaru::Interface } }

  shared_context :application_not_initialised do
    let(:application) { nil }
  end

  shared_context :application_initialised do
    let(:application) { instance_spy(Kangaru::Application) }
  end

  shared_examples :delegates_to_application do |options|
    let(:via) { options[:via] }

    context "when application not initialised" do
      include_context :application_not_initialised

      it "raises an error" do
        expect { subject }.to raise_error("application not set")
      end
    end

    context "when application initialised" do
      include_context :application_initialised

      it "does not raise any errors" do
        expect { subject }.not_to raise_error
      end

      if options[:args]
        it "delegates to the application with arguments" do
          subject
          expect(application).to have_received(via).with(*options[:args]).once
        end
      else
        it "delegates to the application" do
          subject
          expect(application).to have_received(via).once
        end
      end
    end
  end

  describe "#run!" do
    subject(:run!) { target.run!(*argv) }

    let(:argv) { %w[foobar] }

    include_examples :delegates_to_application, via: :run!, args: %w[foobar]
  end

  describe "#config" do
    subject(:config) { target.config }

    include_examples :delegates_to_application, via: :config
  end

  describe "#configure" do
    subject(:configure) { target.configure(env, &block) }

    let(:block) { ->(_config) { :config } }

    let(:current_env) { :some_env }

    before do
      allow(Kangaru).to receive(:env).and_return(current_env)
    end

    shared_examples :skips_config do
      it "does not raise any errors" do
        expect { configure }.not_to raise_error
      end

      it "does not delegate to the application" do
        configure
        expect(application).not_to have_received(:configure)
      end
    end

    shared_examples :applies_config do
      it "does not raise any errors" do
        expect { configure }.not_to raise_error
      end

      it "delegates to the application" do # rubocop:disable RSpec
        configure

        expect(application).to(
          have_received(:configure).with(env).once do |&with_block|
            expect(with_block).to eq(block)
          end
        )
      end
    end

    context "when application not initialised" do
      let(:env) { nil }

      include_context :application_not_initialised

      it "raises an error" do
        expect { configure }.to raise_error("application not set")
      end
    end

    context "when application initialised" do
      include_context :application_initialised

      context "and no env is specified" do
        let(:env) { nil }

        include_examples :applies_config
      end

      context "and env is specified" do
        let(:env) { :some_env }

        context "and not running app in specified env" do
          let(:current_env) { :another_env }

          include_examples :skips_config
        end

        context "and running app in specified env" do
          let(:current_env) { env }

          include_examples :applies_config
        end
      end
    end
  end

  describe "#import_config_from!" do
    subject(:import_config_from!) { target.import_config_from!(path) }

    let(:path) { "/foo/bar/config.yml" }

    include_examples :delegates_to_application,
                     via: :config_path=,
                     args: "/foo/bar/config.yml"
  end

  describe "#apply_config!" do
    subject(:apply_config!) { target.apply_config! }

    include_examples :delegates_to_application, via: :apply_config!
  end

  describe "#database" do
    subject(:database) { target.database }

    include_examples :delegates_to_application, via: :database
  end
end
