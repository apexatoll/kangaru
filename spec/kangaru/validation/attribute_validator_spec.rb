RSpec.describe Kangaru::Validation::AttributeValidator do
  subject(:attribute_validator) { described_class.new(model:, attribute:) }

  let(:model) { SomeModel }

  let(:attribute) { :some_attribute }

  before { stub_const "SomeModel", Class.new }

  pending :implmentation
end
