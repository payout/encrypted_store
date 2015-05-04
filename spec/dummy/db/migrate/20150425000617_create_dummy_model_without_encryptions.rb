class CreateDummyModelWithoutEncryptions < ActiveRecord::Migration
  def change
    create_table :dummy_model_without_encryptions do |t|
      t.string :name
      t.integer :age

      t.timestamps
    end
  end
end
