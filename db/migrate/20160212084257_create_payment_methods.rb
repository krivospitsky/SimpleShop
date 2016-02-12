class CreatePaymentMethods < ActiveRecord::Migration
  def change
    create_table :payment_methods do |t|
      t.string :name
      t.text :description
      t.string :hide
      t.boolean :enabled
      t.integer :sort_order
      t.boolean :use_online

      t.timestamps null: false
    end
  end
end
