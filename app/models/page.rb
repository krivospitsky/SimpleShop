class Page < ActiveRecord::Base
  POSITIONS=[ "menu", "footer", "menu_and_footer"]
	scope :enabled, -> { where(enabled: 't') }
  scope :in_menu, -> { enabled.where('(position="menu" or position="menu_and_footer")') }
  scope :in_footer, -> { enabled.where('(position="footer" or position="menu_and_footer")') }
  mount_uploader :image, ImageUploader

  include  Seoable
end
