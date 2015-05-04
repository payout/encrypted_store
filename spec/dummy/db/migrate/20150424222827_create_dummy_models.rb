class CreateDummyModels < ActiveRecord::Migration
  def change
    create_table :dummy_models do |t|
      t.integer :encryption_key_id
      t.binary  :encrypted_store

      t.timestamps
    end
  end
end
