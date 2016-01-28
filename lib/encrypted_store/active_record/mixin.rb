require 'securerandom'

module EncryptedStore
  module ActiveRecord
    module Mixin
      class << self
        def included(base)
          base.before_save(:_encrypted_store_save,
            if: :encrypted_attributes_changed?)

          base.extend(ClassMethods)
        end

        def descendants
          Rails.application.eager_load! if defined?(Rails) && Rails.application
          ::ActiveRecord::Base.descendants.select { |model| model < Mixin }
        end

        def descendants?
          !descendants.empty?
        end
      end # Class Methods

      module ClassMethods
        def _encrypted_store_data
          @_encrypted_store_data ||= {}
        end

        def attr_encrypted(*args)
          # Store attrs in class data
          _encrypted_store_data[:encrypted_attributes] = args.map(&:to_sym)

          args.each { |arg|
            define_method(arg) { _encrypted_store_get(arg) }
            define_method("#{arg}=") { |value| _encrypted_store_set(arg, value) }
          }
        end
      end # ClassMethods

      ##
      # Instance Methods
      ##
      def reencrypt(encryption_key)
        with_lock do
          # Must decrypt any changes made to the encrypted data, before updating
          # the encryption_key_id.
          _decrypt_encrypted_store
          self.encryption_key_id = encryption_key.id
          _encrypt_encrypted_store
          save!(validate: false)
        end
      end

      ##
      # Completely purges encrypted data for a record
      def purge_encrypted_data
        self.encrypted_store = nil
        self.encryption_key_id = nil
        @_crypto_hash = nil
        save!(validate: false)
      end

      def _encrypted_store_data
        self.class._encrypted_store_data
      end

      def _encryption_key_id
        self.encryption_key_id ||= EncryptionKey.primary_encryption_key.id
      end

      def _crypto_hash
        @_crypto_hash || _decrypt_encrypted_store
      end

      def _decrypt_encrypted_store
        @_crypto_hash = CryptoHash.decrypt(_decrypted_key, self.encrypted_store)
      end

      def _encrypt_encrypted_store
        iter_mag = EncryptedStore.config.iteration_magnitude? ?
                   EncryptedStore.config.iteration_magnitude  :
                   -1

        self.encrypted_store = _crypto_hash.encrypt(
          _decrypted_key,
          EncryptionKeySalt.generate_salt(_encryption_key_id),
          iter_mag
        )
      end

      def _decrypted_key
        EncryptedStore.retrieve_dek(EncryptionKey, _encryption_key_id)
      end

      def _encrypted_store_get(field)
        _crypto_hash[field]
      end

      def _encrypted_store_set(field, value)
        attribute_will_change!(field)
        _crypto_hash[field] = value
      end

      ##
      # Checks if any of the encrypted attributes are in the list of changed
      # attributes
      def encrypted_attributes_changed?
        !(changed.map(&:to_sym) & _encrypted_store_data[:encrypted_attributes])
          .empty?
      end

      def _encrypted_store_save
        _crypto_hash # make sure we have a cached copy of the decrypted data.
        _encrypted_store_sync_key
        _encrypt_encrypted_store
      end

      ##
      # Locks the record (although doesn't reload the attributes) and updates
      # the encryption_key_id if it has changed since the record was originally
      # loaded.
      def _encrypted_store_sync_key
        unless new_record?
          # Obtain a lock without overriding attribute values for this
          # instance. Here `record` will be an updated version of this instance.
          record = self.class.unscoped { self.class.lock.find(id) }

          if record && record.encryption_key_id
            self.encryption_key_id = record.encryption_key_id
          end
        end
      end
    end # Mixin
  end # ActiveRecord
end # EncryptedStore
