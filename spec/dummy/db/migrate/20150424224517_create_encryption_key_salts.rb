class CreateEncryptionKeySalts < ActiveRecord::Migration
  def change
    create_table :encryption_key_salts do |t|
      t.integer :encryption_key_id
      t.binary  :salt
    end
  end
end
