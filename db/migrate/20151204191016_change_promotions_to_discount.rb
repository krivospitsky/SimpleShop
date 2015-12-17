class ChangePromotionsToDiscount < ActiveRecord::Migration
  def up
  	rename_table :promotions, :discounts
    rename_table :products_promotions, :discounts_products
    rename_table :categories_promotions, :categories_discounts


  	remove_column :discounts, :description
  	remove_column :discounts, :sort_order
	remove_column :discounts, :has_banner
  	remove_column :discounts, :banner
  	remove_column :discounts, :send_mail

  	rename_column :discounts_products, :promotion_id, :discount_id
  	rename_column :categories_discounts, :promotion_id, :discount_id
  end
end
