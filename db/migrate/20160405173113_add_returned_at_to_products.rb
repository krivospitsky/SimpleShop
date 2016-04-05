class AddReturnedAtToProducts < ActiveRecord::Migration
  def change
    add_column :products, :returned_at, :datatime
  end
end
