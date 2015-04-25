require 'securerandom'

module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      autoload(:EncryptionKeySalt, 'ribbon/encrypted_store/mixins/active_record_mixin/encryption_key_salt')
      autoload(:EncryptionKey,     'ribbon/encrypted_store/mixins/active_record_mixin/encryption_key')

      class << self
        def included(base)
          base.before_save(:_encrypted_store_save)
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
        ActiveRecord::Base.transaction {
          self.lock!
          _crypto_hash
          _encryption_key_id = encryption_key.id
          _encrypted_store_save
        }
      end

      def reencrypt!(encryption_key)
        reencrypt.tap { save! }
      end

      def _encrypted_store_data
        self.class._encrypted_store_data
      end

      def _encryption_key
        # Encrypt new data with the primary encryption key
        EncryptedStore.decrypt_key(EncryptionKey.find(_encryption_key_id).dek)
      end

      def _encryption_key_id
        @__encryption_key_id ||= self['encryption_key_id'] || EncryptionKey.primary_encryption_key.id
      end

      def _encryption_key_id=(key_id)
        @__encryption_key_id = key_id
      end

      def _crypto_hash
        @_crypto_hash ||= CryptoHash.decrypt(_encryption_key, self['encrypted_store'])
      end

      def _encrypted_store_get(field)
        _crypto_hash[field]
      end

      def _encrypted_store_set(field, value)
        attribute_will_change!(field)
        _crypto_hash[field] = value
      end

      def _encrypted_store_save
        if !(self.changed & _encrypted_store_data[:encrypted_attributes]).empty?
          self['encryption_key_id'] = _encryption_key_id
          puts _crypto_hash.inspect
          self['encrypted_store'] = _crypto_hash.encrypt(_encryption_key, EncryptionKeySalt.generate_salt(_encryption_key_id))
        end
      end
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore