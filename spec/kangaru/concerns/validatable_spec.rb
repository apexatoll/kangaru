RSpec.describe Kangaru::Concerns::Validatable do
  subject(:validatable) { validatable_class.new }

  let(:validatable_class) do
    Class.new { include Kangaru::Concerns::Validatable }
  end

  pending :implementation
end
