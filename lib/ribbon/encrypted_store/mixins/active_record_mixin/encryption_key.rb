require 'securerandom'
require 'base64'

module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      class EncryptionKey < ActiveRecord::Base
        validates_uniqueness_of :primary, if: :primary

        class << self
          def primary_encryption_key
            new_key unless _has_primary?
            where(primary: true).last || last
          end

          def new_key(custom_key=nil)
            dek = custom_key || SecureRandom.random_bytes(32)

            transaction {
              _has_primary? && where(primary: true).first.update_attributes(primary: false)
              create!(dek: dek, primary: true)
            }
          end

          def retire_keys(key_ids=[])
            pkey = primary_encryption_key

            _get_models_with_encrypted_store.each { |model|
              records = key_ids.empty? ? model.where("encryption_key_id != ?", pkey.id)
                                       : model.where("encryption_key_id IN (?)", key_ids)
              records.each { |record| record.reencrypt!(pkey) }
            }
          end

          def rotate_keys
            new_key
            retire_keys
          end

          def _has_primary?
            where(primary: true).exists?
          end

          def _get_table_models
            [].tap { |models|
              Rails.application.eager_load! if defined?(Rails) && Rails.application
              ActiveRecord::Base.descendants.each do |model|
                next if model == EncryptionKey || model == EncryptionKeySalt
                models.push(model)
              end
            }
          end

          def _get_models_with_encrypted_store
            _get_table_models.select { |model| model < Mixins::ActiveRecordMixin }
          end
        end # Class Methods

        def encrypt(store)
          store.encrypt(decrypted_key, generate_salt)
        end

        def generate_salt
          EncryptionKeySalt.generate_salt(self.id)
        end

        def decrypted_key
          EncryptedStore.decrypt_key(self.dek, self.primary)
        end
      end # EncryptionKey
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore