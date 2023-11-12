RSpec.describe "External application config" do
  subject(:apply_config!) { SomeGem.apply_config! }

  before do
    gem.main_file.write(main_file)
    gem.load!
  end

  let(:external_config) { Kangaru.application!.config.external.serialise }

  shared_examples :does_not_set_external_config do
    it "does not raise any errors" do
      expect { apply_config! }.not_to raise_error
    end

    it "does not set any external config" do
      apply_config!
      expect(external_config).to be_empty
    end
  end

  shared_examples :sets_external_config do
    it "does not raise any errors" do
      expect { apply_config! }.not_to raise_error
    end

    it "sets the external config" do
      apply_config!
      expect(external_config).to eq(frodo: { race: "hobbit", age: 48 })
    end
  end

  context "when config_path is not set" do
    let(:main_file) do
      <<~RUBY
        require "kangaru"

        module SomeGem
          extend Kangaru::Initialiser
        end
      RUBY
    end

    include_examples :does_not_set_external_config
  end

  context "when config_path is set" do
    let(:main_file) do
      <<~RUBY
        require "kangaru"

        module SomeGem
          extend Kangaru::Initialiser

          Kangaru.application.config_path = "#{config_path}"
        end
      RUBY
    end

    let(:config_path) { gem.dir.join("config.yml") }

    context "and no config exists at the specified path" do
      include_examples :does_not_set_external_config
    end

    context "and config exists at the specified path" do
      before { config_path.write(config_file) }

      context "and config file is empty" do
        let(:config_file) { "" }

        include_examples :does_not_set_external_config
      end

      context "and config file is not empty" do
        let(:config_file) do
          <<~YAML
            frodo:
              race: hobbit
              age: 48
          YAML
        end

        include_examples :sets_external_config
      end
    end
  end
end
