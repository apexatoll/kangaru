RSpec.describe Kangaru::Database do
  subject(:database) { described_class.new(**attributes) }

  let(:attributes) { { adaptor:, path: }.compact }

  let(:adaptor) { nil }
  let(:path)    { nil }

  let(:sqlite) { instance_spy(Sequel::Database) }

  before do
    allow(Sequel).to receive(:sqlite).with(path).and_return(sqlite)
  end

  describe "#setup!" do
    subject(:setup!) { database.setup! }

    context "when adaptor is not set" do
      it "raises an error" do
        expect { setup! }.to raise_error(
          described_class::AdaptorError, "adaptor can't be blank"
        )
      end
    end

    context "when adaptor is invalid" do
      let(:adaptor) { :invalid }

      it "raises an error" do
        expect { setup! }.to raise_error(
          described_class::AdaptorError, "invalid adaptor 'invalid'"
        )
      end
    end

    context "when adaptor is sqlite" do
      let(:adaptor) { :sqlite }

      context "and path is not set" do
        let(:path) { nil }

        it "raises an error" do
          expect { setup! }.to raise_error(
            described_class::SQLiteError, "path can't be blank"
          )
        end
      end

      context "and path is set" do
        let(:path) { "/some/sqlite/file.sqlite3" }

        it "does not raise any errors" do
          expect { setup! }.not_to raise_error
        end

        it "sets up the sqlite database" do
          setup!
          expect(Sequel).to have_received(:sqlite).with(path).once
        end

        it "sets the handler" do
          expect { setup! }.to change { database.handler }.from(nil).to(sqlite)
        end
      end
    end
  end
end
