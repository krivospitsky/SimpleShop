module Seoable
  extend ActiveSupport::Concern

  included do
    has_one :seo, :as => :seoable, :dependent => :destroy
    accepts_nested_attributes_for :seo, allow_destroy:true, reject_if: :all_blank
  end
end