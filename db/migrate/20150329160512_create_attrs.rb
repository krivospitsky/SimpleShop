class CreateAttrs < ActiveRecord::Migration
  def up
    create_table :attrs do |t|
      t.string :name
      t.string :value
      t.boolean :variantable
      t.integer :product_id

      t.timestamps null: false
    end
    Product.all.each do |prod|
    	prod.attr.keys.each do |key|
    		a=prod.attrs.new
    		a.name=key
    		a.value=prod.attr[key]
    		a.variantable=false
    		a.save!
    	end
    end
    remove_column :products, :attr
  end
end
