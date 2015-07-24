class CreateEncryptionKeySalts < ActiveRecord::Migration
  def change
    create_table :encryption_key_salts do |t|
      t.integer :encryption_key_id
      t.binary  :salt

      t.timestamps
    end

    add_index :encryption_key_salts, [:encryption_key_id, :salt], unique: true
  end
end
