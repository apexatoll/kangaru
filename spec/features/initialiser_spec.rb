RSpec.describe "Initialising Kangaru in a target gem" do
  subject(:require_gem) { gem.load! }

  before do
    gem.path("foobar").write(<<~RUBY)
      module SomeGem
        class Foobar
        end
      end
    RUBY
  end

  describe "initialising application" do
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

        it "sets the application source to the gem main file" do
          expect(application.paths.source).to eq(gem.main_file)
        end

        it "sets the application name to the expected value" do
          expect(application.paths.name).to eq("some_gem")
        end
      end
    end
  end

  describe "setting test environment in RSpec" do
    subject(:run_test) { gem.exec("rspec #{test_file}") }

    let(:test_file) { gem.spec_path("test_spec") }

    before do
      gem.spec_path.mkdir unless gem.spec_path.exist?

      test_file.write(<<~RUBY)
        RSpec.describe do
          it "sets the test environment" do
            expect(Kangaru).to be_test
          end
        end
      RUBY
    end

    include_context :kangaru_initialised

    it "configures Kangaru to the test environment" do
      expect(run_test).not_to include("FAILED")
    end
  end
end
