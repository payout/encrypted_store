require 'securerandom'

module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      class EncryptionKey < ActiveRecord::Base
        self.table_name = "encryption_keys"

        class << self
          def get_primary_key
            primary_keys = where(primary: true)
            primary_keys.empty? ? primary_keys.last : last
          end

          def new_key(custom_key=nil)
            dek = custom_key || SecureRandom.random_bytes(32)
            where(primary: true).first.update_attributes(primary: false)
            create(dek: dek, primary: true)
          end

          def retire_keys(key_ids=[])
            primary_key = get_primary_key

            if key_ids.empty?
              # Re-encrypt all records with the primary encryption key
              _get_models_with_encrypted_store.each { |model|
                model.where("encryption_key_id != ?", primary_key.id).each { |record|
                  _reencrypt_record(primary_key, record)
                }
              }
            else
              # Re-encrypt only the records that have the passed in encryption keys
              _get_models_with_encrypted_store.each { |model|
                model.where("encryption_key_id IN (?)", key_ids).each { |record|
                  _reencrypt_record(primary_key, record)
                }
              }
            end
          end

          def rotate_keys
            new_key
            retire_keys
          end
        end # Class Methods

        private

        def self._reencrypt_record(encryption_key, record)
          prv_dek = find(record.encryption_key_id).dek
          crypto_hash = CryptoHash.decrypt(prv_dek, record.encrypted_store)
          crypto_hash.encrypt(encryption_key.dek, EncryptionKeySalt.generate_salt(encryption_key.id))
        end

        def self._get_table_models
          [].tap { |models|
            ActiveRecord::Base.connection.tables.each do |table|
              next if table.match(/\Aschema_migrations\Z/)
              models.push(table.singularize.camelize.constantize)
            end
          }
        end

        def self._get_models_with_encrypted_store
          get_table_models.reject! { |model|
            !(model.column_names.include?("encrypted_store") && model.column_names.include("encryption_key_id"))
          }
        end
      end # EncryptionKey
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore