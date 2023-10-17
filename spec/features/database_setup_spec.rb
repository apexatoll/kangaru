RSpec.describe "Setting up a database in a target gem", with_gem: :some_gem do
  context "when no database adaptor is set" do
    before do
      gem.main_file.write(<<~RUBY)
        require "kangaru"

        module SomeGem
          extend Kangaru::Initialiser

          configure do |config|
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

          configure do |config|
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

            configure do |config|
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
      context "and migration path is not set" do
        before do
          gem.main_file.write(<<~RUBY)
            require "kangaru"

            module SomeGem
              extend Kangaru::Initialiser

              configure do |config|
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

        it "does not apply any migrations" do
          gem.load!
          expect(Kangaru.application.database.handler.tables).to be_empty
        end
      end

      context "and migration path is set" do
        let(:migration_path) { gem.gem_path("db", "migrate") }

        before do
          gem.gem_path("db").mkdir

          gem.main_file.write(<<~RUBY)
            require "kangaru"

            module SomeGem
              extend Kangaru::Initialiser

              configure do |config|
                config.database.adaptor = :sqlite
                config.database.path = "#{gem.path.join('database.sqlite3')}"
                config.database.migration_path = "#{migration_path}"
              end
            end
          RUBY
        end

        context "and directory does not exist" do
          it "does not raise any errors" do
            expect { gem.load! }.not_to raise_error
          end

          it "sets the database instance" do
            gem.load!
            expect(Kangaru.application.database).to be_a(Kangaru::Database)
          end

          it "does not apply any migrations" do
            gem.load!
            expect(Kangaru.application.database.handler.tables).to be_empty
          end
        end

        context "and directory exists" do
          before do
            migration_path.mkdir
          end

          context "and no migrations are present" do
            it "does not raise any errors" do
              expect { gem.load! }.not_to raise_error
            end

            it "sets the database instance" do
              gem.load!
              expect(Kangaru.application.database).to be_a(Kangaru::Database)
            end

            it "does not apply any migrations" do
              gem.load!
              expect(Kangaru.application.database.handler.tables).to be_empty
            end
          end

          context "and migrations are present" do
            before do
              migration_path.join("1_migration_one.rb").write(migration_one)
              migration_path.join("2_migration_two.rb").write(migration_two)
            end

            let(:migration_one) do
              <<~RUBY
                Sequel.migration do
                  change do
                    create_table :foos do
                      primary_key :id
                    end
                  end
                end
              RUBY
            end

            let(:migration_two) do
              <<~RUBY
                Sequel.migration do
                  change do
                    create_table :bars do
                      primary_key :id
                    end
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

            it "applies the migrations" do
              gem.load!
              expect(Kangaru.application.database.handler.tables).to include(:foos, :bars)
            end
          end
        end
      end
    end
  end
end
