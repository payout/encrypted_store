require 'encrypted_store/version'
require 'ribbon/config'

module EncryptedStore
  require 'encrypted_store/railtie' if defined?(Rails)
  autoload(:CryptoHash, 'encrypted_store/crypto_hash')
  autoload(:Instance,   'encrypted_store/instance')
  autoload(:Errors,     'encrypted_store/errors')
  autoload(:Mixins,     'encrypted_store/mixins')

  class << self
    def included(base)
      if defined?(ActiveRecord) && base < ActiveRecord::Base
        base.send(:include, Mixins::ActiveRecordMixin)
      else
        raise Errors::UnsupportedModelError
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
