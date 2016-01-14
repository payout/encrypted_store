require 'encrypted_store'

class DummyModel < ActiveRecord::Base
  include EncryptedStore
  attr_encrypted :name, :age, "username"

  validates_presence_of :name
end
