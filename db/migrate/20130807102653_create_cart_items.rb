class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.integer :product_id
      t.integer :cart_id
      t.integer :quantity
      t.integer :variant_id

      t.timestamps
    end

    add_index :cart_items, :product_id
    add_index :cart_items, :cart_id

  end
end
