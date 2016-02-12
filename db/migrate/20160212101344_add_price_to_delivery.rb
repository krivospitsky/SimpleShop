class AddPriceToDelivery < ActiveRecord::Migration
  def change
  	    add_column :delivery_methods, :price, :integer
  end
end
