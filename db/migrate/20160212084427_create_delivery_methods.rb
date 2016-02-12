class CreateDeliveryMethods < ActiveRecord::Migration
  def change
    create_table :delivery_methods do |t|
      t.string :name
      t.text :description
      t.string :hide
      t.boolean :enabled
      t.integer :sort_order
      t.integer :min_price
      t.integer :max_price

      t.timestamps null: false
    end
  end
end
