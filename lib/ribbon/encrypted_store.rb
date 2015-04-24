require 'ribbon/encrypted_store/version'
require 'ribbon/config'

module Ribbon
  module EncryptedStore
    autoload(:CryptoHash, 'ribbon/encrypted_store/crypto_hash')
    autoload(:Errors,     'ribbon/encrypted_store/errors')
    autoload(:Mixins,     'ribbon/encrypted_store/mixins')

    def config(&block)
      (@__config ||= Ribbon::Config.new).tap { |config|
        if block_given?
          config.define(&block)
        end
      }
    end

    class << self
      def included(base)
        if defined?(ActiveRecord) && base < ActiveRecord
          base.send(:include, Mixins::ActiveRecordMixin)
        else
          raise Errors::UnsupportedModelError
        end
      end
    end # Class Methods
  end # EncryptedStore
end # Ribbon