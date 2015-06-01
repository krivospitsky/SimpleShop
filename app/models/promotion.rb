class Promotion < ActiveRecord::Base
  include  Seoable
  has_and_belongs_to_many(:categories)

  has_and_belongs_to_many(:products)
  mount_uploader :banner

  scope :enabled, -> { where(enabled: 't') }
#  scope :current, -> { enabled.where('start_at< ? or end_at> ?', Time.now, Time.now) }
  scope :current, -> { enabled.where('(start_at< now() and end_at> now()) or (start_at< now() and end_at is NULL) or (start_at is NULL and end_at< now()) or (start_at is NULL and end_at is NULL)') }

  scope :current_banners, -> {enabled.where(has_banner: 't')}

end
