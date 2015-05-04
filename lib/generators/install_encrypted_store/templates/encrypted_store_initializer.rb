require 'ribbon/encrypted_store'

Ribbon::EncryptedStore.config {
  encrypt_key { |dek| dek }
  decrypt_key { |dek| dek }
}