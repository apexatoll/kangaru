RSpec.describe "Setting up a database in a target gem", :with_gem do
  context "when no database adaptor is set" do
    before do
      gem.main_file.write(<<~RUBY)
        require "kangaru"

        module SomeGem
          extend Kangaru::Initialiser

          Kangaru.application.configure do |config|
          end
        end
      RUBY
    end

    it "does not raise any errors" do
      expect { gem.load! }.not_to raise_error
    end

    it "does not setup a database" do
      gem.load!
      expect(Kangaru.application.database).to be_nil
    end
  end

  context "when an invalid database adaptor is set" do
    before do
      gem.main_file.write(<<~RUBY)
        require "kangaru"

        module SomeGem
          extend Kangaru::Initialiser

          Kangaru.application.configure do |config|
            config.database.adaptor = :invalid
          end
        end
      RUBY
    end

    it "raises an error" do
      expect { gem.load! }.to raise_error(
        Kangaru::Database::AdaptorError, "invalid adaptor 'invalid'"
      )
    end
  end

  context "when adaptor is set to sqlite" do
    context "and database path is not set" do
      before do
        gem.main_file.write(<<~RUBY)
          require "kangaru"

          module SomeGem
            extend Kangaru::Initialiser

            Kangaru.application.configure do |config|
              config.database.adaptor = :sqlite
            end
          end
        RUBY
      end

      it "raises an error" do
        expect { gem.load! }.to raise_error(
          Kangaru::Database::SQLiteError, "path can't be blank"
        )
      end
    end

    context "and database path is set" do
      before do
        gem.main_file.write(<<~RUBY)
          require "kangaru"

          module SomeGem
            extend Kangaru::Initialiser

            Kangaru.application.configure do |config|
              config.database.adaptor = :sqlite
              config.database.path    = "#{gem.path.join('database.sqlite3')}"
            end
          end
        RUBY
      end

      it "does not raise any errors" do
        expect { gem.load! }.not_to raise_error
      end

      it "sets the database instance" do
        gem.load!
        expect(Kangaru.application.database).to be_a(Kangaru::Database)
      end
    end
  end
end
