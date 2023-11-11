RSpec.describe Kangaru::Configurators do
  describe ".classes" do
    subject(:classes) { described_class.classes }

    shared_context :stub_configurators do |options|
      let(:constants) { options[:with] }

      before do
        allow(described_class).to receive(:constants).and_return(constants)

        constants.each do |constant|
          stub_const "#{described_class}::#{constant}", Class.new
        end
      end
    end

    context "when no configurator classes are defined" do
      include_context :stub_configurators, with: []

      it "returns an empty array" do
        expect(classes).to be_empty
      end
    end

    context "when configurator classes are defined" do
      include_context :stub_configurators,
                      with: %i[BaseConfigurator FooConfigurator BazConfigurator]

      before do
        stub_const "#{described_class}::BASE_CONFIGURATORS",
                   [described_class::BaseConfigurator]
      end

      it "returns the expected configurators from the current namespace" do
        expect(classes).to contain_exactly(
          described_class::FooConfigurator,
          described_class::BazConfigurator
        )
      end

      it "does not return base configurators" do
        expect(classes).not_to include(described_class::BaseConfigurator)
      end
    end
  end
end
