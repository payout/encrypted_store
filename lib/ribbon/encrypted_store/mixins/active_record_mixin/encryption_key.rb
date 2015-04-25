require 'securerandom'
require 'base64'

module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      class EncryptionKey < ActiveRecord::Base
        validates_uniqueness_of :primary, if: :primary

        class << self
          def primary_encryption_key
            new_key if !_has_primary?
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

            if key_ids.empty?
              # Re-encrypt all records with the primary encryption key
              _get_models_with_encrypted_store.each { |model|
                model.where("encryption_key_id != ?", pkey.id).each { |record|
                  record.reencrypt!(pkey)
                }
              }
            else
              # Re-encrypt only the records that have the passed in encryption keys
              _get_models_with_encrypted_store.each { |model|
                model.where("encryption_key_id IN (?)", key_ids).each { |record|
                  record.reencrypt!(pkey)
                }
              }
            end
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
              ActiveRecord::Base.connection.tables.each do |table|
                next if table.match(/\Aschema_migrations\Z/)
                models.push(table.singularize.camelize.constantize)
              end
            }
          end

          def _get_models_with_encrypted_store
            _get_table_models.reject! { |model|
              !(model.column_names.include?("encrypted_store") && model.column_names.include("encryption_key_id"))
            }
          end
        end # Class Methods

        def generate_salt
          EncryptionKeySalt.generate_salt(self.id)
        end
      end # EncryptionKey
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore