require 'ribbon/encrypted_store/version'
require 'ribbon/config'

module Ribbon
  module EncryptedStore
    autoload(:CryptoHash, 'ribbon/encrypted_store/crypto_hash')
    autoload(:Instance,   'ribbon/encrypted_store/instance')
    autoload(:Errors,     'ribbon/encrypted_store/errors')
    autoload(:Mixins,     'ribbon/encrypted_store/mixins')

    class << self
      def included(base)
        if defined?(ActiveRecord) && base < ActiveRecord
          base.send(:include, Mixins::ActiveRecordMixin)
        else
          raise Errors::UnsupportedModelError
        end
      end
    end # Class Methods

    module_function

    def method_missing(meth, *args, &block)
      instance.send(meth, *args, &block)
    end

    def instance
      @_instance ||= Instance.new
    end
  end # EncryptedStore
end # Ribbon

# Create a shortcut to the module
EncryptedStore = Ribbon::EncryptedStore