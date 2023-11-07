RSpec.describe "configuration" do
  subject(:application_config) do
    Kangaru.application!.config.test.serialise
  end

  let(:configurator_class) do
    Class.new(Kangaru::Configurators::Configurator) do
      attr_accessor :value
    end
  end

  let(:main_file) do
    <<~RUBY
      require "kangaru"

      module SomeGem
        extend Kangaru::Initialiser

        #{configuration}
      end
    RUBY
  end

  before do
    stub_const "Kangaru::Configurators::TestConfigurator", configurator_class

    gem.main_file.write(main_file)
  end

  describe "setting config" do
    context "when only one configuration call is made" do
      let(:configuration) do
        configure_block(env:) do
          <<~RUBY
            config.test.value = :#{value}
          RUBY
        end
      end

      let(:value) { :foobar }

      context "and no env is specified" do
        let(:env) { nil }

        it "sets the specified configuration" do
          gem.load!
          expect(application_config).to eq(value:)
        end
      end

      context "and env is specified", :stub_env do
        let(:env) { :some_env }

        context "and specified env is not current env" do
          let(:current_env) { :another_env }

          it "does not set the config" do
            gem.load!
            expect(application_config).to be_empty
          end
        end

        context "and specified env is current env" do
          let(:current_env) { env }

          it "sets the config" do
            gem.load!
            expect(application_config).to eq(value:)
          end
        end
      end
    end

    context "when multiple configuration calls are made", :stub_env do
      let(:configuration) do
        <<~RUBY
          #{base_configuration}
          #{env_configuration}
        RUBY
      end

      let(:base_configuration) do
        configure_block(env: nil) do
          <<~RUBY
            config.test.value = :base
          RUBY
        end
      end

      let(:env_configuration) do
        configure_block(env: configured_env) do
          <<~RUBY
            config.test.value = :env
          RUBY
        end
      end

      let(:configured_env) { :some_env }

      context "and not in configured env" do
        let(:current_env) { :another_env }

        it "sets the base value" do
          gem.load!
          expect(application_config).to eq(value: :base)
        end
      end

      context "and in configured env" do
        let(:current_env) { configured_env }

        it "sets the env overridden value" do
          gem.load!
          expect(application_config).to eq(value: :env)
        end
      end
    end
  end

  describe "applying config" do
    subject(:apply_config!) { SomeGem.apply_config! }

    let(:configuration) { nil }

    before { gem.load! }

    context "when config is applied once" do
      it "does not raise any errors" do
        expect { apply_config! }.not_to raise_error
      end
    end

    context "when config is applied more than once" do
      before { SomeGem.apply_config! }

      it "raise an error" do
        expect { apply_config! }.to raise_error("config already applied")
      end
    end
  end
end
