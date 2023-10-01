module Kangaru
  class Database
    include Concerns::AttributesConcern

    class AdaptorError < StandardError
    end

    class SQLiteError < StandardError
    end

    attr_accessor :adaptor, :path

    attr_reader :handler

    def setup!
      raise AdaptorError, "adaptor can't be blank" if adaptor.nil?

      @handler = case adaptor
                 when :sqlite then setup_sqlite!
                 else raise AdaptorError, "invalid adaptor '#{adaptor}'"
                 end
    end

    private

    def setup_sqlite!
      raise SQLiteError, "path can't be blank" if path.nil?

      Sequel.sqlite(path)
    end
  end
end
