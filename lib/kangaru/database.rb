module Kangaru
  class Database
    include Concerns::AttributesConcern

    class AdaptorError < StandardError
    end

    class SQLiteError < StandardError
    end

    attr_accessor :adaptor, :path, :migration_path

    attr_reader :handler

    def setup!
      raise AdaptorError, "adaptor can't be blank" if adaptor.nil?

      @handler = case adaptor
                 when :sqlite then setup_sqlite!
                 else raise AdaptorError, "invalid adaptor '#{adaptor}'"
                 end
    end

    def migrate!
      return unless handler
      return unless migrations_exist?

      Sequel.extension(:migration)

      Sequel::Migrator.run(handler, migration_path)
    end

    private

    def migrations_exist?
      return false if migration_path.nil?

      Dir.exist?(migration_path) && !Dir.empty?(migration_path)
    end

    def setup_sqlite!
      raise SQLiteError, "path can't be blank" if path.nil?

      Sequel.sqlite(path)
    end
  end
end
