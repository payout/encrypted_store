require 'ribbon/encrypted_store'

Ribbon::EncryptedStore.config { |c|
  c.encrypt_key { |dek| dek }
  c.decrypt_key { |dek| dek }
}