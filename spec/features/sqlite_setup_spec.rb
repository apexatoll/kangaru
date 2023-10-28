RSpec.describe "SQLite database setup" do
  subject(:apply_config!) { SomeGem.apply_config! }

  let(:main_file) do
    <<~RUBY
      require "kangaru"

      module SomeGem
        extend Kangaru::Initialiser

        #{config}
      end
    RUBY
  end

  let(:config) do
    build_database_config(adaptor:, path:, migration_path:)
  end

  let(:adaptor) { nil }
  let(:path) { nil }
  let(:migration_path) { nil }

  before do
    gem.main_file.write(main_file)
    gem.load!
  end

  shared_examples :invalid_config do |options|
    it "raises an error" do
      expect { apply_config! }.to raise_error(options[:error])
    end
  end

  shared_examples :valid_config do
    it "does not raise any errors" do
      expect { apply_config! }.not_to raise_error
    end
  end

  shared_examples :does_not_set_up_database do
    it "does not set up the database" do
      apply_config!
      expect(SomeGem.database).to be_nil
    end
  end

  shared_examples :sets_up_database do
    shared_context :write_migrations do |options|
      let(:table_names) { options[:tables] }

      before do
        write_create_table_migrations!(migration_path, table_names)
      end
    end

    shared_examples :connects_to_database do
      it "creates a database" do
        apply_config!
        expect(SomeGem.database).to be_a(Kangaru::Database)
      end

      it "sets the expected database attributes" do
        apply_config!

        expect(SomeGem.database).to have_attributes(
          path: path&.to_s, adaptor:, migration_path: migration_path&.to_s
        )
      end
    end

    shared_examples :does_not_apply_migrations do
      it "does not apply any migrations" do
        apply_config!
        expect(SomeGem.database.handler.tables).to be_empty
      end
    end

    shared_examples :applies_migrations do |options|
      let(:tables) { options[:tables] }

      it "applies the migrations" do
        apply_config!
        expect(SomeGem.database.handler.tables).to include(*tables)
      end
    end

    context "when migration path is not set" do
      let(:migration_path) { nil }

      include_examples :valid_config
      include_examples :connects_to_database
      include_examples :does_not_apply_migrations
    end

    context "when migration path is set" do
      let(:migration_path) { gem.gem_path("migrate") }

      context "and migration path does not exist" do
        include_examples :valid_config
        include_examples :connects_to_database
        include_examples :does_not_apply_migrations
      end

      context "and migration path exists" do
        before { migration_path.mkdir }

        context "and no migrations are defined" do
          include_examples :valid_config
          include_examples :connects_to_database
          include_examples :does_not_apply_migrations
        end

        context "and migrations are defined" do
          include_context :write_migrations, tables: %i[foo bar baz]

          include_examples :valid_config
          include_examples :connects_to_database
          include_examples :applies_migrations, tables: %i[foo bar baz]
        end
      end
    end
  end

  context "when database adaptor is not set" do
    let(:adaptor) { nil }

    include_examples :does_not_set_up_database
  end

  context "when database adaptor is invalid" do
    let(:adaptor) { :invalid }

    include_examples :invalid_config, error: "invalid adaptor 'invalid'"
  end

  context "when database adaptor is valid" do
    let(:adaptor) { :sqlite }

    context "and path is not set" do
      let(:path) { nil }

      include_examples :invalid_config, error: "path can't be blank"
    end

    context "and path is set" do
      let(:path) { db_dir.join("db.sqlite3") }

      let(:db_dir) { gem.gem_path("db") }

      context "and database directory does not exist" do
        include_examples :sets_up_database
      end

      context "and database directory exists" do
        before { db_dir.mkdir }

        include_examples :sets_up_database
      end
    end
  end
end
