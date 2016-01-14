require 'rails/generators/active_record'

module EncryptedStore
  module Generators
    module Upgrade
      class ZeroOneFiveGenerator < Rails::Generators::Base
        include Rails::Generators::Migration

        class << self
          def next_migration_number(*args)
            ::ActiveRecord::Generators::Base.next_migration_number(*args)
          end
        end # Class Methods

        source_root File.expand_path("../templates", __FILE__)

        def create_migrations
          migration_template 'upgrade_encryption_keys_to_015.rb', 'db/migrate/upgrade_encryption_keys_to_015.rb'
          migration_template 'upgrade_encryption_key_salts_to_015.rb', 'db/migrate/upgrade_encryption_key_salts_to_015.rb'
        end
      end # ZeroOneFiveGenerator
    end # Upgrade
  end # Generators
end # EncryptedStore
