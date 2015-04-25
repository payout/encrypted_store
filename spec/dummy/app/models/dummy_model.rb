require 'ribbon/encrypted_store'

class DummyModel < ActiveRecord::Base
  include EncryptedStore
  attr_encrypted :name, :age
end
