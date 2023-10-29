RSpec.describe Kangaru::Command do
  subject(:command) { described_class.new(**attributes) }

  let(:attributes) { { path:, action:, id:, arguments: } }

  let(:path)      { nil }
  let(:action)    { nil }
  let(:id)        { nil }
  let(:arguments) { nil }

  describe "#path" do
    context "when no path is set at initialisation" do
      let(:path) { nil }

      it "returns the default path" do
        expect(command.path).to eq(described_class::DEFAULT_PATH)
      end
    end

    context "when path is set at initialisation" do
      let(:path) { "foo/bar" }

      it "returns the path" do
        expect(command.path).to eq(path)
      end
    end
  end

  describe "#controller_name" do
    subject(:controller_name) { command.controller_name }

    context "when path is not set" do
      let(:path) { nil }

      it "returns the default controller name" do
        expect(controller_name).to eq("DefaultController")
      end
    end

    context "when flat path is set" do
      let(:path) { "foobar" }

      it "returns the expected controller name" do
        expect(controller_name).to eq("FoobarController")
      end
    end

    context "when nested path is set" do
      let(:path) { "foo/bar/baz" }

      it "returns the expected controller name" do
        expect(controller_name).to eq("Foo::Bar::BazController")
      end
    end
  end

  describe "#action" do
    context "when action is not set" do
      let(:action) { nil }

      it "returns the default action" do
        expect(command.action).to eq(described_class::DEFAULT_ACTION)
      end
    end

    context "when action is set" do
      let(:action) { :some_action }

      it "returns the specified action" do
        expect(command.action).to eq(action)
      end
    end
  end

  describe "#view_file" do
    subject(:view_file) { command.view_file }

    let(:application) { instance_spy(Kangaru::Application, view_path:) }
    let(:view_path)   { instance_spy(Pathname) }

    before do
      allow(Kangaru).to receive(:application).and_return(application)
    end

    context "when path is nil" do
      let(:path) { nil }

      context "and action is nil" do
        let(:action) { nil }

        it "delegates to the application" do
          view_file

          expect(application).to have_received(:view_path).with(
            described_class::DEFAULT_PATH,
            described_class::DEFAULT_ACTION.to_s
          ).once
        end

        it "returns the pathname" do
          expect(view_file).to eq(view_path)
        end
      end

      context "and action is set" do
        let(:action) { :some_action }

        it "delegates to the application" do
          view_file

          expect(application).to have_received(:view_path).with(
            described_class::DEFAULT_PATH,
            action.to_s
          ).once
        end

        it "returns the pathname" do
          expect(view_file).to eq(view_path)
        end
      end
    end

    context "when path is set" do
      let(:path) { "foo/bar" }

      context "and action is nil" do
        let(:action) { nil }

        it "delegates to the application" do
          view_file

          expect(application).to have_received(:view_path).with(
            path,
            described_class::DEFAULT_ACTION.to_s
          ).once
        end

        it "returns the pathname" do
          expect(view_file).to eq(view_path)
        end
      end

      context "and action is set" do
        let(:action) { :some_action }

        it "delegates to the application" do
          view_file

          expect(application).to have_received(:view_path).with(
            path,
            action.to_s
          ).once
        end

        it "returns the pathname" do
          expect(view_file).to eq(view_path)
        end
      end
    end
  end
end
