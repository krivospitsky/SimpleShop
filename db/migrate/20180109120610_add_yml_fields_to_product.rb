class AddYmlFieldsToProduct < ActiveRecord::Migration
  def change
    add_column :products, :typePrefix, :string
    add_column :products, :vendor, :string
    add_column :products, :model, :string
    add_column :products, :color, :string
    add_column :products, :yml_name, :string
    add_column :products, :picture_type, :string
  end
end
