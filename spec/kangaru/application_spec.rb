RSpec.describe Kangaru::Application do
  subject(:application) { described_class.new(root_file:, namespace:) }

  let(:root_file) { "/some_app/lib/some_app.rb" }

  let(:namespace) { SomeApp }

  before { stub_const "SomeApp", Module.new }

  describe "#app_dir" do
    subject(:app_dir) { application.app_dir }

    it "returns a string" do
      expect(app_dir).to be_a(String)
    end

    it "returns the expected app directory" do
      expect(app_dir).to eq("/some_app/lib/some_app")
    end
  end
end
