require 'openssl'
require 'json'

module Ribbon::EncryptedStore
  class CryptoHash < Hash
    def initialize(data={})
      super
      merge!(data)
    end

    def encrypt(dek, salt)
      return nil if empty?

      key, iv = _keyiv_gen(dek, salt)

      encryptor = OpenSSL::Cipher::AES256.new(:CBC).encrypt
      encryptor.key = key
      encryptor.iv = iv

      # Packet Header Format (Version 1)
      #
      # |     Byte 0     |     Byte 1     |      ...
      #  ---------------------------------------------------
      # |    Version     |   Salt Length  |     Salt
      #
      _encrypted_header_header(salt) + encryptor.update(self.to_json) + encryptor.final
    end

    def decrypt(dek, data)
      return CryptoHash.new if empty?

      salt = data[0..7]
      data = data[8..-1]

      begin
        key, iv = _keyiv_gen(dek, salt)

        decryptor = OpenSSL::Cipher::AES256.new(:CBC).decrypt
        decryptor.key = key
        decryptor.iv = iv

        new_hash = JSON.parse(decryptor.update(data) + decryptor.final)
        new_hash = Hash[new_hash.map { |k,v| [k.to_sym, v] }]
        self.new(new_hash)
      rescue OpenSSL::Cipher::CipherError
        raise
      end
    end

    private

    def _encrypted_data_header(salt)
      "\x01" + salt.bytes.length.chr + salt
    end

    def _keyiv_gen(key, salt)
      key_and_iv = OpenSSL::PKCS5.pbkdf2_hmac(
        key,
        salt,
        4096,
        48,
        OpenSSL::Digest::SHA256.new
      )

      key = key_and_iv[0..31]
      iv  = key_and_iv[32..-1]

      [key, iv]
    end
  end # CryptoHash
end # Ribbon::EncryptedStore