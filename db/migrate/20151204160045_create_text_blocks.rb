class CreateTextBlocks < ActiveRecord::Migration
  def change
    create_table :text_blocks do |t|
      t.string :name
      t.text :text

      t.timestamps null: false
    end
  end
end
