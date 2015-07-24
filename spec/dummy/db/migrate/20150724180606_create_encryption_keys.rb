class CreateEncryptionKeys < ActiveRecord::Migration
  def change
    create_table :encryption_keys do |t|
      t.binary  :dek
      t.boolean :primary

      t.timestamps
    end

    add_index :encryption_keys, :created_at
  end
end
