RSpec.describe Kangaru::Renderer do
  subject(:renderer) { described_class.new(path) }

  let(:path) do
    instance_spy(Pathname, read: view_contents, exist?: view_exists?)
  end

  let(:view_contents) do
    <<~ERB
      Your name is <%= @name %>, you are <%= @age %> years old.
    ERB
  end

  describe "#render" do
    subject(:render) { renderer.render(binding) }

    context "when view file does not exist" do
      let(:view_exists?) { false }

      it "does not output any text" do
        expect { render }.not_to output.to_stdout
      end
    end

    context "when view file exists" do
      let(:view_exists?) { true }

      context "and instance variables do not exist in binding" do
        let(:expected_output) do
          <<~STRING
            Your name is , you are  years old.
          STRING
        end

        it "outputs the view file contents with nil interpolated" do
          expect { render }.to output(expected_output).to_stdout
        end
      end

      context "and instance variables exist in binding" do
        around do |spec|
          instance_variable_set(:@name, "Foo Bar")
          instance_variable_set(:@age, 30)
          spec.run
          remove_instance_variable(:@name)
          remove_instance_variable(:@age)
        end

        let(:expected_output) do
          <<~STRING
            Your name is Foo Bar, you are 30 years old.
          STRING
        end

        it "outputs the interpolated view file contents" do
          expect { render }.to output(expected_output).to_stdout
        end
      end
    end
  end
end
