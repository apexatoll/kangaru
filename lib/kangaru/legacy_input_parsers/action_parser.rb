module Kangaru
  module LegacyInputParsers
    class ActionParser < InputParser
      using Patches::Inflections

      DEFAULT_ACTION = :default

      def parse
        if command_tokens.count > 1
          command_tokens[-1].to_snakecase.to_sym
        else
          DEFAULT_ACTION
        end
      end
    end
  end
end
