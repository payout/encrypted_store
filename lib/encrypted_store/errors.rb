module EncryptedStore
  module Errors
    class Error < StandardError; end

    # General Errors
    class GeneralError < Error; end
    class UnsupportedModelError < GeneralError; end

    # CryptoHash Errors
    class CryptoHashError < Error; end
    class ChecksumFailedError < CryptoHashError; end
    class InvalidSaltSize < CryptoHashError; end
    class InvalidKeySize < CryptoHashError; end
    class UnsupportedVersionError < CryptoHashError; end
  end # Errors
end # EncryptedStore
