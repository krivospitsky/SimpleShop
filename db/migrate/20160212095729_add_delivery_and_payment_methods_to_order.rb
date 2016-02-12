class AddDeliveryAndPaymentMethodsToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_method, :integer
    add_column :orders, :payment_method, :integer
  end
end
