module Kangaru
  module Initialisers
    module RSpec
      module KangaruHelper
        def run_in_transaction(&block)
          database = Kangaru.application&.database

          return block.call if database.nil?

          database.transaction do
            block.call
            database.rollback_on_exit
          end
        end
      end
    end
  end
end
