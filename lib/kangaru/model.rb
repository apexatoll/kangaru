module Kangaru
  Model = Class.new(Sequel::Model) do
    include Concerns::Validatable
  end

  Model.def_Model(self)
end
