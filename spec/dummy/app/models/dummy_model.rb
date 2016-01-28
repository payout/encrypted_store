require 'encrypted_store'

class DummyModel < ActiveRecord::Base
  include EncryptedStore
  attr_encrypted :name, :age, "username"

  # Validators that read/write to encrypted attributes shouldn't cause problems,
  # particularly when reencrypting records.
  validate { self.name = name }
end
