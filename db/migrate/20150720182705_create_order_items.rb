class CreateOrderItems < ActiveRecord::Migration
  def up
    create_table :order_items do |t|
      t.string :product_name
      t.string :product_sku
      t.integer :product_id
      t.integer :price
      t.integer :discount_price
      t.integer :quantity
      t.integer :order_id

      t.timestamps null: false
    end

    Order.all.each do |order|
      next if order.cart.blank?
      order.cart.cart_items.all.each do |cart_item|
        order_item=order.order_items.new
        order_item.product_name=cart_item.variant.name || cart_item.product.name 
        order_item.product_sku=cart_item.variant.sku
        order_item.product=cart_item.product
        order_item.price=cart_item.variant.price
        order_item.discount_price=cart_item.variant.discount_price
        order_item.quantity=cart_item.quantity
        order_item.save
      end
    end
  end
  def down
    drop_table :order_items 
  end
end
