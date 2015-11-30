class AddExternalIdToVariant < ActiveRecord::Migration
  def change
    add_column :variants, :external_id, :string
    add_index :variants, :external_id
  end
end
