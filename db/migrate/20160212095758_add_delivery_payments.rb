class AddDeliveryPayments < ActiveRecord::Migration
  def change
    create_table :delivery_methods_payment_methods do |t|
      t.integer :delivery_method_id
      t.integer :payment_method_id
	end
  end
end
