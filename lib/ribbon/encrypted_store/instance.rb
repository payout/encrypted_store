module Ribbon::EncryptedStore
  class Instance
    def config(&block)
      (@__config ||= Ribbon::Config.new).tap { |config|
        if block_given?
          config.define(&block)
        end
      }
    end

    def decrypt_key(dek, primary=false)
      config.decrypt_key? ? config.decrypt_key.last.call(dek, primary) : dek
    end

    def encrypt_key(dek, primary=false)
      config.encrypt_key? ? config.encrypt_key.last.call(dek, primary) : dek
    end

    def retrieve_dek(key_model, key_id)
      (@__decrypted_keys ||= {})[key_id] ||= key_model.find(key_id).decrypted_key
    end
  end # Instance
end # Ribbon::EncryptedStore