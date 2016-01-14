require 'rails/generators/active_record'

module EncryptedStore
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      class << self
        def next_migration_number(*args)
          ::ActiveRecord::Generators::Base.next_migration_number(*args)
        end
      end # Class Methods

      source_root File.expand_path("../templates", __FILE__)

      def create_initializer
        copy_file "initializer.rb", "config/initializers/encrypted_store.rb"
      end

      def create_migrations
        migration_template 'create_encryption_keys.rb', 'db/migrate/create_encryption_keys.rb'
        migration_template 'create_encryption_key_salts.rb', 'db/migrate/create_encryption_key_salts.rb'
      end
    end # InstallEncryptedStoreGenerator
  end # Generators
end # EncryptedStore
