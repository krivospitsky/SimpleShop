class AddBarCodeAndDiscountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :card_number, :string
    add_column :users, :discount, :integer
    add_column :users, :name, :string
  end
end
