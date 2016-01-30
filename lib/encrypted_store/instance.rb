module EncryptedStore
  class Instance
    def config(&block)
      (@__config ||= Config.new).tap { |config|
        if block_given?
          config.define(&block)
        end
      }
    end

    def rotate_keys
      EncryptedStore::ActiveRecord.rotate_keys
    end

    ##
    # Preloads the most recent `amount` keys.
    def preload_keys(amount = 12)
      keys = EncryptedStore::ActiveRecord.preload_keys(amount)
      keys.each { |k| (@_decrypted_keys ||= {})[k.id] = k.decrypted_key }
    end

    def decrypt_key(dek, primary = false)
      config.decrypt_key? ? config.decrypt_key.last.call(dek, primary) : dek
    end

    def encrypt_key(dek, primary = false)
      config.encrypt_key? ? config.encrypt_key.last.call(dek, primary) : dek
    end

    def retrieve_dek(key_model, key_id)
      (@_decrypted_keys ||= {})[key_id] ||= key_model.find(key_id).decrypted_key
    end
  end # Instance
end # EncryptedStore
