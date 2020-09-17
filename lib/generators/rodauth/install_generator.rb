require "rails/generators/base"
require "rails/generators/active_record/migration"

module Rodauth
  module Rails
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        include ::ActiveRecord::Generators::Migration

        source_root "#{__dir__}/templates"
        namespace "rodauth:install"

        class_option :primary_key_type, type: :string, desc: "The type for primary key"

        def create_rodauth_migration
          return unless defined?(ActiveRecord::Base)

          migration_template "db/migrate/create_rodauth.rb", File.join(db_migrate_path, "create_rodauth.rb")
        end

        def create_rodauth_initializer
          template "config/initializers/rodauth.rb"
        end

        def create_sequel_initializer
          return unless defined?(ActiveRecord::Base)
          return unless %w[postgresql mysql2 sqlite3].include?(activerecord_adapter)
          return if defined?(Sequel) && !Sequel::DATABASES.empty?

          template "config/initializers/sequel.rb"
        end

        def create_rodauth_app
          template "lib/rodauth_app.rb"
        end

        def create_rodauth_controller
          template "app/controllers/rodauth_controller.rb"
        end

        def create_account_model
          return unless defined?(ActiveRecord::Base)

          template "app/models/account.rb"
        end

        private

        def primary_key_type
          return unless activerecord_at_least?(5, 0)
          super
        end

        def db_migrate_path
          return "db/migrate" unless activerecord_at_least?(5, 0)
          super
        end

        def migration_version
          if activerecord_at_least?(5, 0)
            "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
          end
        end

        def sequel_adapter
          case activerecord_adapter
          when "postgresql" then "postgres#{"ql" if RUBY_ENGINE == "jruby"}"
          when "mysql2"     then "mysql#{"2" unless RUBY_ENGINE == "jruby"}"
          when "sqlite3"    then "sqlite"
          end
        end

        def activerecord_adapter
          ActiveRecord::Base.connection_config.fetch(:adapter)
        end

        def activerecord_at_least?(major, minor)
          ActiveRecord.version >= Gem::Version.new("#{major}.#{minor}")
        end
      end
    end
  end
end
