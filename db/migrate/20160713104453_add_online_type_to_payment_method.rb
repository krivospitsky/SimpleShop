class AddOnlineTypeToPaymentMethod < ActiveRecord::Migration
  def change
    add_column :payment_methods, :online_type, :string
  end
end
