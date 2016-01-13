require 'encrypted_store'

EncryptedStore.config {
  encrypt_key { |dek| dek }
  decrypt_key { |dek| dek }
}
