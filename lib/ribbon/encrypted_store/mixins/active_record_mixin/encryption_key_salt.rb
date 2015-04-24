module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      class EncryptionKeySalt < ActiveRecord::Base
        self.table_name = "encryption_key_salts"

        validates :salt, uniqueness: {scope: :encryption_key_id}

      end # EncryptionKeySalt
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore