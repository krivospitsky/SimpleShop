class AddPassportToOrder < ActiveRecord::Migration
  def change
  	    add_column :orders, :passport, :string
  end
end
