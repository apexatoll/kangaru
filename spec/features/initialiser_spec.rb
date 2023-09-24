RSpec.describe "Initialising Kangaru in a target gem", :with_gem do
  subject(:require_gem) { gem.load! }

  before do
    gem.gem_file("foobar").write(<<~RUBY)
      module SomeGem
        class Foobar
        end
      end
    RUBY
  end

  context "when the target gem does not extend the initialiser" do
    before do
      gem.main_file.write(<<~RUBY)
        require "kangaru"

        module SomeGem
        end
      RUBY
    end

    it "loads the gem module" do
      expect { require_gem }
        .to change { Object.const_defined?(:SomeGem) }
        .from(false)
        .to(true)
    end

    it "does not autoload gem files" do
      expect { require_gem }
        .not_to change { Object.const_defined?("SomeGem::Foobar") }
        .from(false)
    end

    it "does not set the Kangaru application reference" do
      expect { require_gem }.not_to change { Kangaru.application }.from(nil)
    end

    it "does not define the run! method in the gem's root module" do
      require_gem
      expect(SomeGem).not_to respond_to(:run!)
    end
  end

  context "when the target gem extends the initialiser" do
    before do
      gem.main_file.write(<<~RUBY)
        require "kangaru"

        module SomeGem
          extend Kangaru::Initialiser
        end
      RUBY
    end

    it "loads the gem module" do
      expect { require_gem }
        .to change { Object.const_defined?("SomeGem") }
        .from(false)
        .to(true)
    end

    it "autoloads gem files" do
      expect { require_gem }
        .to change { Object.const_defined?("SomeGem::Foobar") }
        .from(false)
        .to(true)
    end

    it "sets the Kangaru application reference" do
      expect { require_gem }
        .to change { Kangaru.application }
        .from(nil)
        .to(a_kind_of(Kangaru::Application))
    end

    it "defines the run! method in the gem's root module" do
      require_gem
      expect(SomeGem).to respond_to(:run!)
    end

    describe "application reference" do
      subject(:application) { Kangaru.application }

      before { require_gem }

      it "sets the application root dir to the gem lib path" do
        expect(application.root_dir).to eq(gem.lib_path)
      end

      it "sets the application root file to the main gem file" do
        expect(application.root_file).to eq(gem.main_file)
      end
    end
  end
end