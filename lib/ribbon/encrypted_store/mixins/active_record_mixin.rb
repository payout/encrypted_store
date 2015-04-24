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
        def _crypto_hash
          @_crypto_hash ||= (self.encrypted_store && CryptoHash.decrypt(self.encrypted_store)) || CryptoHash.new
        end
      end # ClassMethods

      ##
      # Instance Methods

      def attr_encrypted(*args)
        args.each { |arg|
          define_method(arg) { _encrypted_store_get(field) }
          define_method("#{arg}=") { |value| _encrypted_store_set(field, value) }
        }
      end

      def _encrypted_store_get(field)
        crypto_hash[field]
      end

      def _encrypted_store_set(field, value)
        @_crypto_hash_changed = true
        crypto_hash[field] = value
      end

      def _encrypted_store_save
        self.encrypted_store = @_crypto_hash.encrypt
      end
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore