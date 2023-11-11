RSpec.describe Kangaru::Configurators do
  describe ".classes", :stub_application do
    subject(:classes) { described_class.classes }

    shared_context :application_set do
      before do
        allow(application)
          .to receive(:const_get)
          .with(:Configurators)
          .and_return(application_configurators)

        stub_const "Application::Configurators", application_configurators
      end
    end

    shared_context :stub_kangaru_configurators do |constants|
      before do
        stub_configurators(constants:, namespace: described_class)
      end
    end

    shared_context :stub_application_configurators do |constants|
      before do
        stub_configurators(constants:, namespace: Application::Configurators)
      end
    end

    def stub_configurators(constants:, namespace:)
      allow(namespace).to receive(:constants).and_return(constants)

      constants.each do |constant|
        stub_const "#{namespace}::#{constant}", Class.new
      end
    end

    context "when Kangaru configurators are not defined" do
      include_context :stub_kangaru_configurators, []

      context "and application is not set" do
        let(:application) { nil }

        it "returns no configurator classes" do
          expect(classes).to be_empty
        end
      end

      context "and application is set" do
        include_context :application_set

        context "and application does not define Configurators module" do
          let(:application_configurators) { nil }

          it "returns no configurator classes" do
            expect(classes).to be_empty
          end
        end

        context "and application defines Configurators module" do
          let(:application_configurators) { Module.new }

          context "and application does not define configurators" do
            include_context :stub_application_configurators, []

            it "returns no configurator classes" do
              expect(classes).to be_empty
            end
          end

          context "and application defines configurators" do
            include_context :stub_application_configurators,
                            %i[FooConfigurator BarConfigurator]

            it "returns the application configurator classes" do
              expect(classes).to contain_exactly(
                Application::Configurators::FooConfigurator,
                Application::Configurators::BarConfigurator
              )
            end
          end
        end
      end
    end

    context "when Kangaru configurators are defined" do
      include_context :stub_kangaru_configurators,
                      %i[FooConfigurator BarConfigurator]

      context "and application is not set" do
        let(:application) { nil }

        it "returns the Kangaru configurator classes" do
          expect(classes).to contain_exactly(
            described_class::FooConfigurator,
            described_class::BarConfigurator
          )
        end
      end

      context "and application is set" do
        include_context :application_set

        context "and application does not define Configurators module" do
          let(:application_configurators) { nil }

          it "returns the Kangaru configurator classes" do
            expect(classes).to contain_exactly(
              described_class::FooConfigurator,
              described_class::BarConfigurator
            )
          end
        end

        context "and application defines Configurators module" do
          let(:application_configurators) { Module.new }

          context "and application does not define configurators" do
            include_context :stub_application_configurators, []

            it "returns the Kangaru configurator classes" do
              expect(classes).to contain_exactly(
                described_class::FooConfigurator,
                described_class::BarConfigurator
              )
            end
          end

          context "and application defines configurators" do
            include_context :stub_application_configurators,
                            %i[FooConfigurator BarConfigurator]

            it "returns Kangaru and application configurator classes" do
              expect(classes).to contain_exactly(
                described_class::FooConfigurator,
                described_class::BarConfigurator,
                Application::Configurators::FooConfigurator,
                Application::Configurators::BarConfigurator
              )
            end
          end
        end
      end
    end
  end
end
