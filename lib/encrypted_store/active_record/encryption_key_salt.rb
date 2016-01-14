require 'securerandom'

module EncryptedStore
  module ActiveRecord
    class EncryptionKeySalt < ::ActiveRecord::Base
      validates :salt, uniqueness: { scope: :encryption_key_id }

      class << self
        def generate_salt(encryption_key_id)
          loop do
            salt = SecureRandom.random_bytes(16)
            begin
              salt_record = self.new
              salt_record.encryption_key_id = encryption_key_id
              salt_record.salt = salt
              salt_record.save!
              return salt
            rescue ::ActiveRecord::RecordNotUnique => e
              next
            end
          end
        end
      end # Class Methods
    end # EncryptionKeySalt
  end # ActiveRecord
end # EncryptedStore
