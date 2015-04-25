require 'openssl'
require 'json'
require 'zlib'

module Ribbon::EncryptedStore
  class CryptoHash < Hash
    def initialize(data={})
      super
      merge!(data)
    end

    def encrypt(dek, salt)
      return nil if empty?
      raise Errors::SaltTooBigError if salt.bytes.length > 255
      puts "ENCRYPT SALT: #{salt}"

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
      data_packet = _encrypted_data_header(salt) + encryptor.update(self.to_json) + encryptor.final
      _append_crc32(data_packet)
    end

    def self.decrypt(dek, data)
      puts "decrypt; #{data.inspect}"
      return CryptoHash.new if data.nil?
      salt, data = _split_binary_data(data)

      begin
        key, iv = _keyiv_gen(dek, salt)

        decryptor = OpenSSL::Cipher::AES256.new(:CBC).decrypt
        decryptor.key = key
        decryptor.iv = iv

        new_hash = JSON.parse(decryptor.update(data) + decryptor.final)
        new_hash = Hash[new_hash.map { |k,v| [k.to_sym, v] }]
        CryptoHash.new(new_hash)
      rescue Exception => e
        raise
      rescue OpenSSL::Cipher::CipherError
        raise
      end
    end

    private

    def self._keyiv_gen(key, salt)
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

    def self._split_binary_data(encrypted_data)
      # Split encrypted data and CRC
      bytes, crc = [encrypted_data[0..-9].bytes, encrypted_data[-8..-1]]

      version     = bytes[0]
      salt_length = bytes[1]

      salt_start_index = 2
      salt_end_index   = salt_start_index + salt_length - 1
      salt = bytes[salt_start_index..salt_end_index].pack('c*')
      puts "DECRYPT SALT: #{salt.inspect}"
      data = bytes[salt_end_index+1..-1].pack('c*')

      crc = encrypted_data[-8..-1]
      raise Errors::ChecksumFailedError unless crc == Zlib.crc32(encrypted_data[0..-9]).to_s(16)

      [salt, data]
    end

    def _encrypted_data_header(salt)
      "\x01" + salt.bytes.length.chr + salt
    end

    def _keyiv_gen(key, salt)
      self.class._keyiv_gen(key, salt)
    end

    def _append_crc32(data)
      data + Zlib.crc32(data).to_s(16)
    end
  end # CryptoHash
end # Ribbon::EncryptedStore