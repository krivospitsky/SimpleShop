class ChangeOkIdType < ActiveRecord::Migration
  def up
  	change_column :products, :ok_id, :bigint
  	change_column :categories, :ok_id, :bigint
  end
end
