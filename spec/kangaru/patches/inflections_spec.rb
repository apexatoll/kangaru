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
      subject(:class_name) { string.to_class_name(suffix:) }

      let(:inflector_class) { Kangaru::Inflectors::ClassInflector }

      let(:inflector) { instance_double(inflector_class, inflect: "SomeClass") }

      before do
        allow(inflector_class).to receive(:new).and_return(inflector)
      end

      context "when no suffix is specified" do
        let(:suffix) { nil }

        it "instantiates a Class inflector" do
          class_name
          expect(inflector_class).to have_received(:new).with(string).once
        end

        it "inflects and returns the output" do
          expect(class_name).to eq(inflector.inflect)
        end
      end

      context "when suffix is specified" do
        let(:suffix) { "foobar" }

        it "instantiates a Class inflector" do
          class_name
          expect(inflector_class).to have_received(:new).with(string).once
        end

        it "inflects and returns the output with the suffix" do
          expect(class_name).to eq("#{inflector.inflect}Foobar")
        end
      end
    end

    describe "#to_constant_name" do
      subject(:constant_name) { string.to_constant_name }

      include_examples :delegates_to_inflector,
                       inflector: Kangaru::Inflectors::ConstantInflector
    end

    describe "#to_snakecase" do
      subject(:snakecased) { string.to_snakecase }

      include_examples :delegates_to_inflector,
                       inflector: Kangaru::Inflectors::SnakecaseInflector
    end

    describe "#to_humanised" do
      subject(:snakecased) { string.to_humanised }

      include_examples :delegates_to_inflector,
                       inflector: Kangaru::Inflectors::HumanInflector
    end
  end
end
