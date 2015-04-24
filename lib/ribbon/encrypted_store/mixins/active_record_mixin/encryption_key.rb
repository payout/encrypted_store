module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      class EncryptionKey < ActiveRecord::Base
        self.table_name = "encryption_keys"

      end # EncryptionKey
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore