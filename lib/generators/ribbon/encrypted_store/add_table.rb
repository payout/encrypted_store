module Ribbon::EncryptedStore
  class AddTable < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    argument :table_name, :type => :string

    def create_migrations
      generate "migration", "add_encrypted_store_to_#{table_name.underscore} encryption_key_id:integer encrypted_store:binary"
    end
  end # AddTable
end # Ribbon::EncryptedStore