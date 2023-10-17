RSpec.describe "Setting up a database in a target gem", with_gem: :some_gem do
  before { gem.main_file.write(main_file) }

  let(:main_file) do
    <<~RUBY
      require "kangaru"

      module SomeGem
        extend Kangaru::Initialiser

        configure do |config|
          #{config}
        end
      end
    RUBY
  end

  context "when no database adaptor is set" do
    let(:config) { nil }

    it "does not raise any errors" do
      expect { gem.load! }.not_to raise_error
    end

    it "does not setup a database" do
      gem.load!
      expect(Kangaru.application.database).to be_nil
    end
  end

  context "when an invalid database adaptor is set" do
    let(:config) do
      <<~RUBY
        config.database.adaptor = :invalid
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
      let(:config) do
        <<~RUBY
          config.database.adaptor = :sqlite
        RUBY
      end

      it "raises an error" do
        expect { gem.load! }.to raise_error(
          Kangaru::Database::SQLiteError, "path can't be blank"
        )
      end
    end

    context "and database path is set" do
      let(:database_path) { gem.path.join("database.sqlite3") }

      let(:tables) { Kangaru.application.database.handler.tables }

      shared_examples :sets_database do
        it "does not raise any errors" do
          expect { gem.load! }.not_to raise_error
        end

        it "sets the application database instance" do
          gem.load!
          expect(Kangaru.application.database).to be_a(Kangaru::Database)
        end
      end

      shared_examples :does_not_migrate_database do
        it "does not apply any migrations" do
          gem.load!
          expect(tables).to be_empty
        end
      end

      context "and migration path is not set" do
        let(:config) do
          <<~RUBY
            config.database.adaptor = :sqlite
            config.database.path = "#{database_path}"
          RUBY
        end

        include_examples :sets_database
        include_examples :does_not_migrate_database
      end

      context "and migration path is set" do
        let(:config) do
          <<~RUBY
            config.database.adaptor = :sqlite
            config.database.path = "#{database_path}"
            config.database.migration_path = "#{migration_path}"
          RUBY
        end

        let(:db_path) { gem.gem_path("db") }

        let(:migration_path) { db_path.join("migrate") }

        before { db_path.mkdir }

        context "and migration directory does not exist" do
          include_examples :sets_database
          include_examples :does_not_migrate_database
        end

        context "and migration directory exists" do
          before { migration_path.mkdir }

          context "and no migrations are present" do
            include_examples :sets_database
            include_examples :does_not_migrate_database
          end

          context "and migrations are present" do
            let(:table_names) { %i[foo bar baz] }

            before do
              table_names.each.with_index(1) do |table, index|
                write_migration!(table, index)
              end
            end

            def write_migration!(table, index)
              migration_path.join("#{index}_#{table}.rb").write(<<~RUBY)
                Sequel.migration do
                  change do
                    create_table :#{table} do
                      primary_key :id
                    end
                  end
                end
              RUBY
            end

            include_examples :sets_database

            it "applies the migrations" do
              gem.load!
              expect(tables).to include(*table_names)
            end
          end
        end
      end
    end
  end
end
