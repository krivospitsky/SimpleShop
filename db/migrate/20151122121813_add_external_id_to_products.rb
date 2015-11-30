class AddExternalIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :external_id, :string
    add_index :products, :external_id
  end
end
