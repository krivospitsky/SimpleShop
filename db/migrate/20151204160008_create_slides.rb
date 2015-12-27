class CreateSlides < ActiveRecord::Migration
  def up
    create_table :slides do |t|
      t.string :name
      t.boolean :enabled
      t.string :image
      t.string :url
      t.date :start_at
      t.date :end_at
      t.integer :sort_order

      t.timestamps null: false
    end
    Promotion.all.each do |p|
      if p.has_banner
        s=Slide.new
        s.name=p.name
        s.start_at=p.start_at
        s.end_at=p.end_at
        s.enabled=p.enabled
        s.image = p.banner.file
        s.save
        p.delete
      end
    end
  end
end
