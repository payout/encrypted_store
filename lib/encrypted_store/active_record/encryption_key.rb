require 'securerandom'
require 'base64'

module EncryptedStore
  module ActiveRecord
    class EncryptionKey < ::ActiveRecord::Base
      validates_uniqueness_of :primary, if: :primary

      class << self
        def primary_encryption_key
          new_key unless _has_primary?
          where(primary: true).last || last
        end

        def new_key(custom_key = nil)
          dek = custom_key || SecureRandom.random_bytes(32)

          transaction {
            _has_primary? && where(primary: true).first.update_attributes(primary: false)
            _create_primary_key(dek)
          }
        end

        def retire_keys(key_ids = [])
          pkey = primary_encryption_key

          ActiveRecord::Mixin.descendants.each { |model|
            records = key_ids.empty? ? model.where("encryption_key_id != ?", pkey.id)
                                     : model.where("encryption_key_id IN (?)", key_ids)

            records.find_in_batches do |batch|
              batch.each { |record| record.reencrypt(pkey) }
            end
          }

          pkey
        end

        ##
        # Preload the most recent `amount` keys.
        def preload(amount)
          primary_encryption_key # Ensure there's at least a primary key
          order('id DESC').limit(amount)
        end

        def rotate_keys
          new_key
          retire_keys
        end

        def _has_primary?
          where(primary: true).exists?
        end

        def _create_primary_key(dek)
          self.new.tap { |key|
            key.dek = EncryptedStore.encrypt_key(dek, true)
            key.primary = true
            key.save!
          }
        end
      end # Class Methods

      def decrypted_key
        EncryptedStore.decrypt_key(self.dek, self.primary)
      end
    end # EncryptionKey
  end # ActiveRecord
end # EncryptedStore
