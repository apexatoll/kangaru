RSpec.describe Kangaru::Initialiser do
  subject(:namespace) { Namespace }

  before do
    stub_const "Namespace", Module.new

    allow(Kangaru::Application).to receive(:new).and_return(application)

    allow_any_instance_of(Kernel).to receive(:caller).and_return([callsite])
  end

  after do
    if Kangaru.instance_variable_defined?(:@application)
      Kangaru.remove_instance_variable(:@application)
    end
  end

  let(:application) { instance_spy(Kangaru::Application) }

  describe ".extended" do
    subject(:extended) { namespace.extend(described_class) }

    shared_examples :initialises_application do |**options|
      let(:expected_dir)  { options[:dir] }
      let(:expected_name) { options[:name] }

      it "instantiates an application with the expected attributes" do
        extended

        expect(Kangaru::Application)
          .to have_received(:new)
          .with(dir: expected_dir, name: expected_name, namespace:)
          .once
      end

      it "sets the Kangaru application to the created application" do
        expect { extended }
          .to change { Kangaru.application }
          .to(application)
      end

      it "sets up the application" do
        extended
        expect(application).to have_received(:setup).once
      end
    end

    context "when calling file is not in a gem structure" do
      let(:callsite) { "/foo/bar/some_file.rb:23 initialize" }

      include_examples :initialises_application,
                       dir: "/foo/bar", name: "some_file"
    end

    context "when calling file is in a gem structure" do
      let(:callsite) { "/foo/bar/some_gem/lib/some_gem.rb:23 initialize" }

      include_examples :initialises_application,
                       dir: "/foo/bar", name: "some_gem"
    end
  end
end
