require 'securerandom'

module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      class EncryptionKeySalt < ActiveRecord::Base
        validates :salt, uniqueness: {scope: :encryption_key_id}

        class << self
          def generate_salt(encryption_key_id)
            loop do
              salt = SecureRandom.random_bytes(16)
              begin
                create!(encryption_key_id: encryption_key_id, salt: salt)
                return salt
              rescue ActiveRecord::RecordNotUnique => e
                next
              end
            end
          end
        end # Class Methods
      end # EncryptionKeySalt
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore