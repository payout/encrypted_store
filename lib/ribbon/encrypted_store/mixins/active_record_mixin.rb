require 'securerandom'

module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      autoload(:EncryptionKeySalt, 'ribbon/encrypted_store/mixins/active_record_mixin/encryption_key_salt')
      autoload(:EncryptionKey,     'ribbon/encrypted_store/mixins/active_record_mixin/encryption_key')

      class << self
        def included(base)
          base.before_save(:_encrypted_store_save)
          base.belongs_to(:encryption_key, class_name: EncryptionKey.name)
          base.extend(ClassMethods)
        end
      end # Module Methods

      module ClassMethods
        def _encrypted_store_data
          @_encrypted_store_data ||= {}
        end

        def attr_encrypted(*args)
          # Store attrs in class data
          _encrypted_store_data[:encrypted_attributes] = args

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
        self.encryption_key = encryption_key
        @_reencrypting = true
      end

      def reencrypt!(encryption_key)
        reencrypt(encryption_key).tap { save! }
      end

      def _encrypted_store_data
        self.class._encrypted_store_data
      end

      def _encryption_key
        self.encryption_key ||= EncryptionKey.primary_encryption_key
      end

      def _crypto_hash
        @_crypto_hash ||= CryptoHash.decrypt(_encryption_key.decrypted_key, self.encrypted_store)
      end

      def _encrypted_store_get(field)
        _crypto_hash[field]
      end

      def _encrypted_store_set(field, value)
        attribute_will_change!(field)
        _crypto_hash[field] = value
      end

      def _encrypted_store_save
        if !(self.changed & _encrypted_store_data[:encrypted_attributes]).empty? || @_reencrypting
          # Obtain a lock without overriding attribute values for this record.
          record = self.class.unscoped { self.class.lock.find(id) } unless new_record?

          unless @_reencrypting
            self.encryption_key = record.encryption_key if record && record.encryption_key
          end

          @_reencrypting = false
          self.encrypted_store = self.encryption_key.encrypt(_crypto_hash)
        end
      end
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore