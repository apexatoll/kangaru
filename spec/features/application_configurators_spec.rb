RSpec.describe "defining application-level configurators" do
  before { gem.main_file.write(main_file) }

  let(:configurator) do
    <<~RUBY
      module SomeGem
        module Configurators
          class ExampleConfigurator < Kangaru::Configurator
            attr_accessor :attribute
          end
        end
      end
    RUBY
  end

  shared_context :no_custom_config_specified do
    let(:config) { nil }
  end

  shared_context :custom_config_specified do
    let(:config) do
      <<~RUBY
        config.example.attribute = :foobar
      RUBY
    end
  end

  shared_context :configurator_defined do
    before do
      gem.path("configurators", "example_configurator").write(configurator)
    end

    after { Kangaru::Config.undef_method(:example) }
  end

  shared_examples :valid_config do
    it "does not raise an error on load" do
      expect { gem.load! }.not_to raise_error
    end
  end

  shared_examples :does_not_set_configurator do
    it "does not set a reader for the configurator on the config object" do
      gem.load!
      expect(SomeGem.config).not_to respond_to(:example)
    end
  end

  shared_examples :sets_configurator do |options|
    let(:expected_values) { options[:values] }

    let(:instance) { SomeGem.config.example }

    it "sets a reader for the configurator on the config object" do
      gem.load!
      expect(SomeGem.config).to respond_to(:example)
    end

    it "instantiates the custom configurator" do
      gem.load!
      expect(instance).to be_a(SomeGem::Configurators::ExampleConfigurator)
    end

    it "sets the expected configurator values" do
      gem.load!
      expect(instance.serialise).to eq(expected_values)
    end
  end

  context "when application does not define Configurators namespace" do
    let(:main_file) do
      <<~RUBY
        require "kangaru"

        module SomeGem
          extend Kangaru::Initialiser

          configure do |config|
            #{config}
          end

          apply_config!
        end
      RUBY
    end

    context "and no custom configuration is specified" do
      include_context :no_custom_config_specified

      include_examples :valid_config
      include_examples :does_not_set_configurator
    end

    context "and custom configuration is specified" do
      include_context :custom_config_specified

      it "raises an error on load" do
        expect { gem.load! }.to raise_error(
          NoMethodError, /undefined method.*example.*#{described_class}/
        )
      end
    end
  end

  context "when application defines Configurators namespace" do
    let(:main_file) do
      <<~RUBY
        require "kangaru"

        module SomeGem
          extend Kangaru::Initialiser

          configure do |config|
            #{config}
          end

          module Configurators
          end

          apply_config!
        end
      RUBY
    end

    before { gem.path("configurators", ext: nil).mkdir }

    context "and no configurators are defined" do
      context "and no custom configuration is specified" do
        include_context :no_custom_config_specified

        include_examples :valid_config
        include_examples :does_not_set_configurator
      end

      context "and custom configuration is specified" do
        include_context :custom_config_specified

        it "raises an error on load" do
          expect { gem.load! }.to raise_error(
            NoMethodError, /undefined method.*example.*#{described_class}/
          )
        end
      end
    end

    context "and configurator is defined" do
      include_context :configurator_defined

      context "and no custom configuration is specified" do
        include_context :no_custom_config_specified

        include_context :valid_config
        include_context :sets_configurator, values: {}
      end

      context "and custom configuration is specified" do
        include_context :custom_config_specified

        include_context :valid_config
        include_context :sets_configurator, values: { attribute: :foobar }
      end
    end
  end
end
