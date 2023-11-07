RSpec.describe Kangaru::Initialiser do
  subject(:namespace) { Namespace }

  before do
    stub_const "Namespace", Module.new

    allow(Kangaru::Application).to receive(:new).and_return(application)
    allow(Kangaru).to receive(:eager_load)

    allow_any_instance_of(Kernel).to receive(:caller).and_return([callsite])
  end

  after do
    if Kangaru.instance_variable_defined?(:@application)
      Kangaru.remove_instance_variable(:@application)
    end
  end

  let(:application) { instance_spy(Kangaru::Application) }

  let(:callsite) { "#{source}:23 initialize" }

  describe ".extended" do
    subject(:extended) { namespace.extend(described_class) }

    before do
      allow(Namespace).to receive(:extend).and_call_original
    end

    shared_examples :initialises_application do |**options|
      let(:expected_dir)  { options[:dir] }
      let(:expected_name) { options[:name] }

      it "instantiates an application with the expected attributes" do
        extended

        expect(Kangaru::Application)
          .to have_received(:new)
          .with(source:, namespace:)
          .once
      end

      it "sets the Kangaru application to the created application" do
        expect { extended }.to change { Kangaru.application }.to(application)
      end

      it "eager loads the Initialisers namespace" do
        extended

        expect(Kangaru)
          .to have_received(:eager_load)
          .with(Kangaru::Initialisers)
          .once
      end

      it "injects the application interface into the namespace" do
        extended

        expect(Namespace)
          .to have_received(:extend)
          .with(Kangaru::InjectedMethods)
          .once
      end
    end

    context "when calling file is not in a gem structure" do
      let(:source) { "/foo/bar/some_file.rb" }

      include_examples :initialises_application,
                       dir: "/foo/bar", name: "some_file"
    end

    context "when calling file is in a gem structure" do
      let(:source) { "/foo/bar/some_gem/lib/some_gem.rb" }

      include_examples :initialises_application,
                       dir: "/foo/bar", name: "some_gem"
    end
  end
end
