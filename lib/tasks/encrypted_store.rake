require 'encrypted_store'

namespace :encrypted_store do
  task :new_key, [:custom_key] => :environment do |t, args|
    new_key = EncryptedStore::ActiveRecord.new_key(args[:custom_key])
    puts "Created new primary key: #{new_key.id}"
  end

  task :retire_keys, [:key_ids] => :environment do |t, args|
    key_ids = (args[:key_ids] && args[:key_ids].split(" ")) || []
    new_primary_key = EncryptedStore::ActiveRecord.retire_keys(key_ids)
    puts "Retired key_ids: #{key_ids} and reencrypted records with primary key: #{new_primary_key.id}"
  end

  task :rotate_keys => :environment do |t, args|
    new_primary_key = EncryptedStore::ActiveRecord.rotate_keys
    puts "Retired all key_ids and reencrypted records with new primary key: #{new_primary_key.id}"
  end
end
