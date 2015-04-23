require 'ribbon/encrypted_store/version'

module Ribbon
  module EncryptedStore
    autoload(:CryptoHash, 'ribbon/encrypted_store/crypto_hash')
    autoload(:Errors,     'ribbon/encrypted_store/errors')
  end # EncryptedStore
end # Ribbon