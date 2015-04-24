require 'ribbon/encrypted_store'

namespace :encrypted_store do
  task :new_key, [:custom_key] => :environment do |t, args|
    EncryptedStore::Mixins::ActiveRecordMixin::EncryptionKey.new_key(args[:custom_key])
  end

  task :retire_keys, [:key_ids] => :environment do |t, args|
    EncryptedStore::Mixins::ActiveRecordMixin::EncryptionKey.retire_keys(args[:key_ids])
  end

  task :rotate_keys => :environment do |t, args|
    EncryptedStore::Mixins::ActiveRecordMixin::EncryptionKey.rotate_keys
  end
end