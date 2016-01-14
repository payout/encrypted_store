module EncryptedStore
  module ActiveRecord
    autoload(:Mixin,             'encrypted_store/active_record/mixin')
    autoload(:EncryptionKeySalt, 'encrypted_store/active_record/encryption_key_salt')
    autoload(:EncryptionKey,     'encrypted_store/active_record/encryption_key')

    class << self
      ##
      # Preloads the most recent `amount` keys.
      def preload_keys(amount)
        EncryptionKey.preload(amount) if Mixin.descendants?
      end

      def new_key(custom_key = nil)
        EncryptionKey.new_key(custom_key) if Mixin.descendants?
      end

      def retire_keys(key_ids = [])
        EncryptionKey.retire_keys(key_ids) if Mixin.descendants?
      end

      def rotate_keys
        EncryptionKey.rotate_keys if Mixin.descendants?
      end
    end # Class Methods
  end # ActiveRecord
end # EncryptedStore
