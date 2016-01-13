require 'openssl'
require 'json'
require 'zlib'

module EncryptedStore
  class CryptoHash < Hash
    def initialize(data={})
      super()
      merge!(data)
    end

    ##
    # Encrypts the hash using the data encryption key and salt.
    #
    # Returns a blob:
    # | Byte 0   |   Byte 1    |        Byte 2       | Bytes 3...S | Bytes S+1...E  | Bytes E+1..E+4 |
    # ------------------------------------------------------------------------------------------------
    # | Version  | Salt Length | Iteration Magnitude |     Salt    | Encrypted Data |     CRC32      |
    def encrypt(dek, salt, iter_mag=10)
      return nil if empty?
      raise Errors::InvalidSaltSize, 'too long' if salt.bytes.length > 255

      key, iv = _keyiv_gen(dek, salt, iter_mag)

      encryptor = OpenSSL::Cipher::AES256.new(:CBC).encrypt
      encryptor.key = key
      encryptor.iv = iv

      data_packet = _encrypted_data_header_v2(salt, iter_mag) + encryptor.update(self.to_json) + encryptor.final
      _append_crc32(data_packet)
    end

    class << self
      def decrypt(dek, data)
        return CryptoHash.new unless data
        salt, iter_mag, data = _split_binary_data(data)

        key, iv = _keyiv_gen(dek, salt, iter_mag)

        decryptor = OpenSSL::Cipher::AES256.new(:CBC).decrypt
        decryptor.key = key
        decryptor.iv = iv

        new_hash = JSON.parse(decryptor.update(data) + decryptor.final)
        new_hash = Hash[new_hash.map { |k,v| [k.to_sym, v] }]
        CryptoHash.new(new_hash)
      end

      def _keyiv_gen(key, salt, iter_mag)
        if iter_mag == -1
          raise Errors::InvalidKeySize, 'must be exactly 256 bits' unless key.bytes.length == 32
          raise Errors::InvalidSaltSize, 'must be exactly 128 bits' unless salt.bytes.length == 16
          iv = salt
        else
          digest = OpenSSL::Digest::SHA256.new
          key_and_iv = OpenSSL::PKCS5.pbkdf2_hmac(key, salt, 1 << iter_mag, 48, digest)

          key = key_and_iv[0..31]
          iv  = key_and_iv[32..-1]
        end

        [key, iv]
      end

      def _split_binary_data(encrypted_data)
        # Split encrypted data and CRC
        bytes = encrypted_data.bytes

        version = bytes[0]
        version_method = "_split_binary_data_v#{version}"

        if respond_to?(version_method)
          send(version_method, encrypted_data)
        else
          raise Errors::UnsupportedVersionError, "Unsupported encrypted data version: #{version}"
        end
      end

      def _split_binary_data_v1(encrypted_data)
        bytes = encrypted_data.bytes
        salt_length = bytes[1]

        salt_start_index = 2
        salt_end_index   = salt_start_index + salt_length - 1
        salt = bytes[salt_start_index..salt_end_index].pack('c*')
        data = bytes[salt_end_index+1..-5].pack('c*')

        crc = bytes[-4..-1]
        raise Errors::ChecksumFailedError unless crc == _calc_crc32(encrypted_data[0..-5]).bytes

        [salt, 12, data]
      end

      def _split_binary_data_v2(encrypted_data)
        bytes = encrypted_data.bytes
        salt_length = bytes[1]
        iter_mag    = bytes[2].chr.unpack('c').first

        salt_start_index = 3
        salt_end_index   = salt_start_index + salt_length - 1
        salt = bytes[salt_start_index..salt_end_index].pack('c*')
        data = bytes[salt_end_index+1..-5].pack('c*')

        crc = bytes[-4..-1]
        raise Errors::ChecksumFailedError unless crc == _calc_crc32(encrypted_data[0..-5]).bytes

        [salt, iter_mag, data]
      end


      def _calc_crc32(data)
        [Zlib.crc32(data)].pack('N')
      end
    end # Class Methods

    private

    ##
    # Generates the version 1 encrypted data header:
    # |     Byte 0     |     Byte 1     |  Bytes 2...S
    # ---------------------------------------------------
    # |    Version     |   Salt Length  |     Salt
    #
    def _encrypted_data_header_v1(salt)
      "\x01" + salt.bytes.length.chr + salt
    end

    ##
    # Generates the version 2 encrypted data header:
    # |     Byte 0     |     Byte 1     |         Byte 2       | Bytes 3...S
    # ----------------------------------------------------------------------
    # |    Version     |   Salt Length  |  Iteration Magnitude |    Salt
    #
    def _encrypted_data_header_v2(salt, iter_mag)
      "\x02" + salt.bytes.length.chr + [iter_mag].pack('c') + salt
    end

    def _keyiv_gen(key, salt, iter_mag)
      self.class._keyiv_gen(key, salt, iter_mag)
    end

    def _append_crc32(data)
      data + _calc_crc32(data)
    end

    def _calc_crc32(data)
      self.class._calc_crc32(data)
    end
  end # CryptoHash
end # EncryptedStore
