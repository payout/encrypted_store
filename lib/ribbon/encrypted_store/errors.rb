module Ribbon::EncryptedStore
  module Errors
    class Error < StandardError; end

    # General Errors
    class GeneralError < Error; end
    class UnsupportedModelError < GeneralError; end

    # CryptoHash Errors
    class CryptoHashError < Error; end
    class ChecksumFailedError < CryptoHashError; end
    class SaltTooBigError < CryptoHashError; end
    class UnsupportedVersionError < CryptoHashError; end
  end # Errors
end # Ribbon::EncryptedStore
