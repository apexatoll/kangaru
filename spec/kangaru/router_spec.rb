RSpec.describe Kangaru::Router do
  subject(:router) { described_class.new(command, namespace:) }

  let(:command) { instance_double(Kangaru::Command, controller:, action:) }

  let(:controller) { "SomeController" }

  let(:action) { :some_action }

  let(:namespace) { SomeNamespace }

  before { stub_const "SomeNamespace", Module.new }

  describe "#initialize" do
    it "sets the attributes" do
      expect(router).to have_attributes(command:, namespace:)
    end
  end
end
