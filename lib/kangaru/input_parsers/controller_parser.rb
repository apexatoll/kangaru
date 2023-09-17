module Kangaru
  module InputParsers
    class ControllerParser < InputParser
      using Patches::Inflections

      DEFAULT_CONTROLLER = "DefaultController".freeze
      CONTROLLER_SUFFIX  = "Controller".freeze

      def parse
        return DEFAULT_CONTROLLER if use_default_controller?

        controller_name
      end

      private

      # The first command token is always assumed as a controller.
      # Removes an assumed action if there are more than one command tokens.
      def controller_tokens
        @controller_tokens ||= command_tokens.tap do |tokens|
          tokens.pop if tokens.count > 1
        end
      end

      def use_default_controller?
        controller_tokens.empty?
      end

      def controller_name
        controller_tokens.join("/").to_class_name + CONTROLLER_SUFFIX
      end
    end
  end
end
