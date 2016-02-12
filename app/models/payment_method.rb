class PaymentMethod < ActiveRecord::Base

  scope :enabled, -> { where(enabled: 't') }

end
