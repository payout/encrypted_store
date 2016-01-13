require 'securerandom'

module EncryptedStore
  module Mixins
    module ActiveRecordMixin
      autoload(:EncryptionKeySalt, 'encrypted_store/mixins/active_record_mixin/encryption_key_salt')
      autoload(:EncryptionKey,     'encrypted_store/mixins/active_record_mixin/encryption_key')

      class << self
        def included(base)
          base.before_save(:_encrypted_store_save)
          base.extend(ClassMethods)
        end

        def descendants
          Rails.application.eager_load! if defined?(Rails) && Rails.application
          ActiveRecord::Base.descendants.select { |model| model < Mixins::ActiveRecordMixin }
        end

        def descendants?
          !descendants.empty?
        end

        ##
        # Preloads the most recent `amount` keys.
        def preload_keys(amount)
          EncryptionKey.preload(amount) if descendants?
        end
      end # Module Methods

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
        _crypto_hash
        self.encryption_key_id = encryption_key.id
        @_reencrypting = true
      end

      def reencrypt!(encryption_key)
        reencrypt(encryption_key).tap { save! }
      end

      def _encrypted_store_data
        self.class._encrypted_store_data
      end

      def _encryption_key_id
        self.encryption_key_id ||= EncryptionKey.primary_encryption_key.id
      end

      def _crypto_hash
        @_crypto_hash ||= CryptoHash.decrypt(_decrypted_key, self.encrypted_store)
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

      def _encrypted_store_save
        if !(self.changed.map(&:to_sym) & _encrypted_store_data[:encrypted_attributes]).empty? || @_reencrypting
          # Obtain a lock without overriding attribute values for this record.
          record = self.class.unscoped { self.class.lock.find(id) } unless new_record?

          unless @_reencrypting
            self.encryption_key_id = record.encryption_key_id if record && record.encryption_key_id
          end

          iter_mag = EncryptedStore.config.iteration_magnitude? ?
                     EncryptedStore.config.iteration_magnitude  :
                     -1

          @_reencrypting = false
          self.encrypted_store = _crypto_hash.encrypt(
            _decrypted_key,
            EncryptionKeySalt.generate_salt(_encryption_key_id),
            iter_mag
          )
        end
      end
    end # ActiveRecordMixin
  end # Mixins
end # EncryptedStore
