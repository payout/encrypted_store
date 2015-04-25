require 'securerandom'

module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      class EncryptionKeySalt < ActiveRecord::Base
        validates :salt, uniqueness: {scope: :encryption_key_id}

        class << self
          def generate_salt(encryption_key_id)
            salt = SecureRandom.random_bytes(16)
            loop do
              begin
                create(encryption_key_id: encryption_key_id, salt: salt)
              rescue ActiveRecord::RecordNotUnique => e
                salt = SecureRandom.random_bytes(16)
                next
              end
              break
            end

            salt
          end
        end
      end # EncryptionKeySalt
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore