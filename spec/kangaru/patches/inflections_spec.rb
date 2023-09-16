RSpec.describe Kangaru::Patches::Inflections do
  using described_class

  describe String do
    subject(:string) { "foo/bar/baz" }

    shared_examples :delegates_to_inflector do |options|
      let(:inflector_class) { options[:inflector] }

      let(:inflector) { instance_double(inflector_class, inflect: "output") }

      before do
        allow(inflector_class).to receive(:new).and_return(inflector)
      end

      it "instantiates a #{options[:inflector]}" do
        subject
        expect(inflector_class).to have_received(:new).with(string).once
      end

      it "inflects and returns the output" do
        expect(subject).to eq(inflector.inflect)
      end
    end

    describe "#to_class_name" do
      subject(:class_name) { string.to_class_name }

      include_examples :delegates_to_inflector,
                       inflector: Kangaru::Inflectors::ClassInflector
    end

    describe "#to_constant_name" do
      subject(:constant_name) { string.to_constant_name }

      include_examples :delegates_to_inflector,
                       inflector: Kangaru::Inflectors::ConstantInflector
    end
  end
end
