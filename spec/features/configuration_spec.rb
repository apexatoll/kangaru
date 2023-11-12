RSpec.describe "configuration" do
  subject(:application_config) { SomeGem.config.test.serialise }

  let(:main_file) do
    <<~RUBY
      require "kangaru"

      module SomeGem
        extend Kangaru::Initialiser

        #{configuration}
      end
    RUBY
  end

  let(:configurator_class) do
    <<~RUBY
      module SomeGem
        module Configurators
          class TestConfigurator < Kangaru::Configurator
            attr_accessor :value
          end
        end
      end
    RUBY
  end

  before do
    gem.main_file.write(main_file)

    gem.path("configurators", ext: nil).mkdir
    gem.path("configurators", "test_configurator").write(configurator_class)
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

    let(:configuration) do
      configure_block do
        <<~RUBY
          config.test.required_attribute = :some_value
        RUBY
      end
    end

    let(:configurator_class) do
      <<~RUBY
        module SomeGem
          module Configurators
            class TestConfigurator < Kangaru::Configurator
              attr_accessor :required_attribute

              validates :required_attribute, required: true
            end
          end
        end
      RUBY
    end

    before { gem.load! }

    context "when config is applied more than once" do
      before { SomeGem.apply_config! }

      it "raise an error" do
        expect { apply_config! }.to raise_error("config already applied")
      end
    end

    context "when config is applied once" do
      context "and config is not valid" do
        let(:configuration) { nil }

        it "raises an error" do
          expect { apply_config! }.to raise_error(
            Kangaru::Application::InvalidConfigError,
            "Required attribute can't be blank"
          )
        end
      end

      context "and config is valid" do
        let(:configuration) do
          configure_block do
            <<~RUBY
              config.test.required_attribute = :some_value
            RUBY
          end
        end

        it "does not raise any errors" do
          expect { apply_config! }.not_to raise_error
        end
      end
    end
  end
end
