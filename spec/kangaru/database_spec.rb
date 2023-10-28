RSpec.describe Kangaru::Database do
  subject(:database) { described_class.new(**attributes) }

  let(:attributes) { { adaptor:, path:, migration_path: }.compact }

  let(:adaptor)        { nil }
  let(:path)           { nil }
  let(:migration_path) { nil }

  let(:sqlite) { instance_spy(Sequel::Database) }

  before do
    allow(FileUtils).to receive(:mkdir_p)
    allow(Sequel).to receive(:sqlite).with(path).and_return(sqlite)
    allow(Sequel::Model).to receive(:plugin)
  end

  describe "#setup!" do
    subject(:setup!) { database.setup! }

    context "when adaptor is not set" do
      it "raises an error" do
        expect { setup! }.to raise_error(
          "adaptor can't be blank"
        )
      end
    end

    context "when adaptor is invalid" do
      let(:adaptor) { :invalid }

      it "raises an error" do
        expect { setup! }.to raise_error(
          "invalid adaptor 'invalid'"
        )
      end
    end

    context "when adaptor is sqlite" do
      let(:adaptor) { :sqlite }

      context "and path is not set" do
        let(:path) { nil }

        it "raises an error" do
          expect { setup! }.to raise_error(
            "path can't be blank"
          )
        end
      end

      context "and path is set" do
        let(:path) { "/some/sqlite/file.sqlite3" }

        it "does not raise any errors" do
          expect { setup! }.not_to raise_error
        end

        it "creates the directory if necessary" do
          setup!
          expect(FileUtils).to have_received(:mkdir_p).with("/some/sqlite").once
        end

        it "sets up the sqlite database" do
          setup!
          expect(Sequel).to have_received(:sqlite).with(path).once
        end

        it "installs sequel plugins" do
          setup!

          described_class::PLUGINS.each do |plugin|
            expect(Sequel::Model).to have_received(:plugin).with(plugin)
          end
        end

        it "sets the handler" do
          expect { setup! }.to change { database.handler }.from(nil).to(sqlite)
        end
      end
    end
  end

  describe "#migrate!" do
    subject(:migrate!) { database.migrate! }

    before do
      Sequel.extension(:migration)

      allow(Sequel).to receive(:extension)
      allow(Sequel::Migrator).to receive(:run)

      database.instance_variable_set(:@handler, handler)
    end

    let(:handler) { sqlite }

    shared_examples :does_not_run_migrations do
      it "does not raise any errors" do
        expect { migrate! }.not_to raise_error
      end

      it "does not import the Sequel migration extension" do
        migrate!
        expect(Sequel).not_to have_received(:extension)
      end

      it "does not run the migrations" do
        migrate!
        expect(Sequel::Migrator).not_to have_received(:run)
      end
    end

    shared_examples :runs_migrations do
      it "does not raise any errors" do
        expect { migrate! }.not_to raise_error
      end

      it "imports the Sequel migration extension" do
        migrate!
        expect(Sequel).to have_received(:extension).with(:migration).once
      end

      it "runs the migrations" do
        migrate!

        expect(Sequel::Migrator)
          .to have_received(:run)
          .with(sqlite, migration_path)
      end
    end

    context "when migration_path is not set" do
      let(:migration_path) { nil }

      include_examples :does_not_run_migrations
    end

    context "when migration_path is set" do
      let(:migration_path) { "/foo/bar/some_gem/db/migrate" }

      before do
        allow(Dir).to receive(:exist?).with(migration_path).and_return(exists?)
        allow(Dir).to receive(:empty?).with(migration_path).and_return(empty?)
      end

      context "and handler is not set" do
        let(:handler) { nil }
        let(:exists?) { true }
        let(:empty?)  { false }

        include_examples :does_not_run_migrations
      end

      context "and handler is set" do
        let(:handler) { sqlite }

        context "and migration directory does not exist" do
          let(:exists?) { false }
          let(:empty?) { true }

          include_examples :does_not_run_migrations
        end

        context "and migration directory exists" do
          let(:exists?) { true }

          context "and the migration directory is empty" do
            let(:empty?) { true }

            include_examples :does_not_run_migrations
          end

          context "and the migration directory is not empty" do
            let(:empty?) { false }

            include_examples :runs_migrations
          end
        end
      end
    end
  end
end
