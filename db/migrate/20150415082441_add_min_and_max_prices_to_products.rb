class AddMinAndMaxPricesToProducts < ActiveRecord::Migration
  def up
    add_column :products, :min_price, :integer
    add_column :products, :max_price, :integer

    Product.all.each do |prod|
    	prices=prod.variants.map {|v| v.price}   
    	prod.min_price=prices.min
    	prod.max_price=prices.max
    	prod.save!
	end
  end
end
