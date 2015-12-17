class Slide < ActiveRecord::Base
	mount_uploader :image

	include RankedModel
	ranks :sort_order

	scope :enabled, -> { where(enabled: 't') }
	scope :current, -> { enabled.where('(start_at< now() and end_at> now()) or (start_at< now() and end_at is NULL) or (start_at is NULL and end_at< now()) or (start_at is NULL and end_at is NULL)') }
end
