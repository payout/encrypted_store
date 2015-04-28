class InstallEncryptedStoreGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def create_initializer
    copy_file "encrypted_store_initializer.rb", "config/initializers/encrypted_store.rb"
  end

  def create_migrations
    generate "migration", "create_encryption_keys dek:binary primary:boolean"
    generate "migration", "create_encryption_key_salts salt:binary encryption_key_id:integer"
    rake "db:migrate"
  end
end # InstallEncryptedStoreGenerator
