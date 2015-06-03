class CreateVariantAttrs < ActiveRecord::Migration
  def up
    create_table :variant_attrs do |t|
      t.string :name
      t.string :value
      t.integer :variant_id

      t.timestamps null: false
    end
    Variant.all.each do |var|
    	var.attr.keys.each do |key|
    		a=var.attrs.new
    		a.name=key
    		a.value=var.attr[key]
    		a.save
    	end
    end
    remove_column :variants, :attr
  end
end
