RSpec.describe Kangaru::Configurators do
  describe ".classes" do
    subject(:classes) { described_class.classes }

    context "when no configurator classes are defined" do
      before do
        allow(described_class)
          .to receive(:constants)
          .and_return([])
      end

      it "returns an empty array" do
        expect(classes).to be_empty
      end
    end

    context "when configurator classes are defined" do
      before do
        allow(described_class)
          .to receive(:constants)
          .and_return(%i[BaseConfigurator SomeConfigurator AnotherConfigurator])

        stub_const "#{described_class}::BASE_CONFIGURATORS", [base_configurator]
      end

      around do |spec|
        described_class.const_set(:BaseConfigurator, base_configurator)
        described_class.const_set(:SomeConfigurator, some_configurator)
        described_class.const_set(:AnotherConfigurator, another_configurator)
        spec.run
        described_class.send(:remove_const, :BaseConfigurator)
        described_class.send(:remove_const, :SomeConfigurator)
        described_class.send(:remove_const, :AnotherConfigurator)
      end

      let(:base_configurator)    { Class.new }
      let(:some_configurator)    { Class.new }
      let(:another_configurator) { Class.new }

      it "returns the expected configurators from the current namespace" do
        expect(classes).to contain_exactly(
          some_configurator, another_configurator
        )
      end

      it "does not return base configurators" do
        expect(classes).not_to include(base_configurator)
      end
    end
  end
end
