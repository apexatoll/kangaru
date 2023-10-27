module DatabaseSetupHelper
  def build_database_config(adaptor:, path:, migration_path:)
    <<~RUBY
      configure do
        #{adaptor && adaptor_config(adaptor)}
        #{path && path_config(path)}
        #{migration_path && migration_path_config(migration_path)}
      end
    RUBY
  end

  def write_create_table_migrations!(migration_path, table_names)
    table_names.each.with_index(1) do |table, index|
      migration_path.join("#{index}_create_#{table}.rb").write(<<~RUBY)
        Sequel.migration do
          change do
            create_table :#{table} do
              primary_key :id
            end
          end
        end
      RUBY
    end
  end

  private

  def adaptor_config(adaptor)
    <<~RUBY
      config.database.adaptor = :#{adaptor}
    RUBY
  end

  def path_config(path)
    <<~RUBY
      config.database.path = "#{path}"
    RUBY
  end

  def migration_path_config(migration_path)
    <<~RUBY
      config.database.migration_path = "#{migration_path}"
    RUBY
  end
end
