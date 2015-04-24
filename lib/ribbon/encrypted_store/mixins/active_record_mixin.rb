module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      class << self
        def included(base)
          base.before_save(:_encrypted_store_save)
          base.extend(ClassMethods)
        end
      end # Module Methods

      module ClassMethods
        def _encryption_key
          config.decrypt_key(config.decrypt_key(EncryptionKey(self.encrypted_key_id)))
        end

        def _crypto_hash
          @_crypto_hash ||= CryptoHash.decrypt(self.encrypted_store, _encryption_key)
        end

        def attr_encrypted(*args)
          args.each { |arg|
            define_method(arg) { _encrypted_store_get(field) }
            define_method("#{arg}=") { |value| _encrypted_store_set(field, value) }
          }
        end
      end # ClassMethods

      ##
      # Instance Methods
      ##
      def _crypto_hash
        self.class._crypto_hash
      end

      def _encrypted_store_get(field)
        crypto_hash[field]
      end

      def _encrypted_store_set(field, value)
        @_crypto_hash_changed = true
        crypto_hash[field] = value
      end

      def _encrypted_store_save
        if @_encrypted_store_changed
          self.encrypted_store = @_crypto_hash.encrypt
        end
      end
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore