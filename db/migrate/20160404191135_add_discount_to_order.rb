class AddDiscountToOrder < ActiveRecord::Migration
  def change
  	    add_column :orders, :card_number, :string
  	    add_column :orders, :discount, :integer
  end
end
