class AddReturnedAtToProducts < ActiveRecord::Migration
  def up
    add_column :products, :returned_at, :datetime

    Product.all.each do |p| 
    	p.returned_at=p.created_at
    	p.save
    end
  end
end
