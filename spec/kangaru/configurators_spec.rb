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
          .and_return(%i[SomeConfigurator AnotherConfigurator])
      end

      around do |spec|
        described_class.const_set(:SomeConfigurator, some_configurator)
        described_class.const_set(:AnotherConfigurator, another_configurator)
        spec.run
        described_class.send(:remove_const, :SomeConfigurator)
        described_class.send(:remove_const, :AnotherConfigurator)
      end

      let(:some_configurator)    { Class.new }
      let(:another_configurator) { Class.new }

      it "returns the expected classes" do
        expect(classes).to contain_exactly(
          some_configurator, another_configurator
        )
      end
    end
  end
end
