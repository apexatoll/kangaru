module Kangaru
  class Database
    extend Forwardable

    include Concerns::AttributesConcern

    PLUGINS = %i[
      enum
      timestamps
    ].freeze

    attr_accessor :adaptor, :path, :migration_path

    attr_reader :handler

    def setup!
      raise "adaptor can't be blank" if adaptor.nil?

      @handler = case adaptor
                 when :sqlite then setup_sqlite!
                 else raise "invalid adaptor '#{adaptor}'"
                 end
    end

    def migrate!
      return unless handler
      return unless migrations_exist?

      Sequel.extension(:migration)

      Sequel::Migrator.run(handler, migration_path)
    end

    def_delegators :handler, :rollback_on_exit, :tables, :transaction

    private

    def migrations_exist?
      return false if migration_path.nil?

      Dir.exist?(migration_path) && !Dir.empty?(migration_path)
    end

    def setup_sqlite!
      raise "path can't be blank" if path.nil?

      FileUtils.mkdir_p(File.dirname(path))

      Sequel.sqlite(path).tap do
        PLUGINS.each { |plugin| Sequel::Model.plugin(plugin) }
      end
    end
  end
end
