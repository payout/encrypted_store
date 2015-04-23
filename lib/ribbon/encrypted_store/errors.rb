module Ribbon::EncryptedStore
  module Errors
    class Error < StandardError; end

    # CryptoHash Errors
    class SaltTooBigError < Error; end
  end # Errors
end # Ribbon::EncryptedStore