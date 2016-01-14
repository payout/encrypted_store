class AddUnencryptedValueToDummyModel < ActiveRecord::Migration
  def change
    add_column :dummy_models, :unencrypted_value, :string
  end
end
