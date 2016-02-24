class AddDeliveryAndPaymentMethodsToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_method_id, :integer
    add_column :orders, :payment_method_id, :integer
  end
end
