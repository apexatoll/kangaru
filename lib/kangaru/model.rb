module Kangaru
  Model = Class.new(Sequel::Model) do
    include Validatable
  end

  Model.def_Model(self)
end
