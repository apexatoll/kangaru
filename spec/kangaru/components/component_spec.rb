RSpec.describe Kangaru::Component do
  subject(:component) { described_class.new }

  let(:renderer) { instance_spy(Kangaru::Renderer) }

  before do
    allow(Kangaru::Renderer).to receive(:new).and_return(renderer)
  end

  describe "#render" do
    subject(:render) { component.render }

    let(:component_path) do
      Object.const_source_location(described_class.name).first
    end

    let(:view_path) do
      Pathname.new(component_path.gsub(/\.rb$/, ".erb"))
    end

    it "infers the correct view file path" do
      render
      expect(Kangaru::Renderer).to have_received(:new).with(view_path).once
    end

    it "renders the view file" do
      render
      expect(renderer).to have_received(:render).once
    end
  end
end
