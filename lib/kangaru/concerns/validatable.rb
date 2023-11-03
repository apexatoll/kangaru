module Kangaru
  module Concerns
    module Validatable
      extend Concern

      def errors
        @errors ||= []
      end
    end
  end
end
