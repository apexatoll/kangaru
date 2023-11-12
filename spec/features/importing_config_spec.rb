RSpec.describe "importing external config" do
  before do
    gem.main_file.write(main_file)
    gem.path("configurators", ext: nil).mkdir
    gem.path("configurators", "custom_configurator").write(configurator)
  end

  let(:main_file) do
    <<~RUBY
      require "kangaru"

      module SomeGem
        extend Kangaru::Initialiser

        import_config_from! "#{config_path}"

        apply_config!
      end
    RUBY
  end

  let(:configurator) do
    <<~RUBY
      module SomeGem
        module Configurators
          class CustomConfigurator < Kangaru::Configurator
            attr_accessor :some_setting
          end
        end
      end
    RUBY
  end

  shared_examples :does_not_import_config do
    it "does not raise any errors" do
      expect { gem.load! }.not_to raise_error
    end

    it "does not import any configuration settings" do
      gem.load!
      expect(SomeGem.config.custom.serialise).to be_empty
    end
  end

  shared_examples :imports_config do |**settings|
    it "does not raise any errors" do
      expect { gem.load! }.not_to raise_error
    end

    it "does not import any configuration settings" do
      gem.load!
      expect(SomeGem.config.custom.serialise).to eq(settings)
    end
  end

  context "when application config path is not defined" do
    let(:config_path) { nil }

    include_examples :does_not_import_config
  end

  context "when application config path is defined" do
    let(:config_path) { gem.path("config", ext: :yml) }

    context "and config file does not exist" do
      include_examples :does_not_import_config
    end

    context "and config file exists" do
      before { config_path.write(config_file) }

      context "and file is empty" do
        let(:config_file) { nil }

        include_examples :does_not_import_config
      end

      context "and file is not empty" do
        let(:config_file) do
          <<~YAML
            #{key}:
              some_setting: "foobar"
          YAML
        end

        context "and config settings do not correspond to a configurator" do
          let(:key) { "invalid" }

          include_examples :does_not_import_config
        end

        context "and config settings correspond to a configurator" do
          let(:key) { "custom" }

          include_examples :imports_config, some_setting: "foobar"
        end
      end
    end
  end
end
