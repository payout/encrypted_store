class CreateEncryptionKeys < ActiveRecord::Migration
  def change
    create_table :encryption_keys do |t|
      t.binary  :dek
      t.boolean :primary
    end
  end
end
