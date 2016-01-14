require 'encrypted_store/version'

module EncryptedStore
  require 'encrypted_store/railtie' if defined?(Rails)
  autoload(:Config,       'encrypted_store/config')
  autoload(:CryptoHash,   'encrypted_store/crypto_hash')
  autoload(:Instance,     'encrypted_store/instance')
  autoload(:Errors,       'encrypted_store/errors')
  autoload(:ActiveRecord, 'encrypted_store/active_record')

  class << self
    def included(base)
      if defined?(::ActiveRecord) && base < ::ActiveRecord::Base
        base.send(:include, ActiveRecord::Mixin)
      else
        fail Errors::UnsupportedModelError
      end
    end

    def method_missing(meth, *args, &block)
      instance.send(meth, *args, &block)
    end

    def instance
      @__instance ||= Instance.new
    end
  end # Class Methods
end # EncryptedStore
