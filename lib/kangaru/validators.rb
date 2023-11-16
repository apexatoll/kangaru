module Kangaru
  module Validators
    using Patches::Inflections

    def self.get(name)
      class_name = name.to_s.to_class_name(suffix: :validator)

      from_kangaru(class_name) || from_application(class_name) ||
        raise("#{class_name} is not defined")
    end

    def self.from_kangaru(class_name)
      return unless const_defined?(class_name)

      const_get(class_name)
    end

    def self.from_application(class_name)
      namespace = Kangaru.application&.const_get(:Validators)

      return unless namespace&.const_defined?(class_name)

      namespace.const_get(class_name)
    end

    private_class_method :from_kangaru
    private_class_method :from_application
  end
end
