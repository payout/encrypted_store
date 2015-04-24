module Ribbon::EncryptedStore
  class Instance
    def config(&block)
      (@__config ||= Ribbon::Config.new).tap { |config|
        if block_given?
          config.define(&block)
        end
      }
    end

    def decrypt_key(*args)
      config.decrypt_key? ? config.decrypt_key.call(*args).first : args
    end

    def encrypt_key(*args)
      config.encrypt_key? ? config.encrypt_key.call(*args).first : args
    end
  end # Instance
end # Ribbon::EncryptedStore