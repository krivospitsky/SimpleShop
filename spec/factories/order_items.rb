# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order_item do
    product_name ""
    product_sku ""
    product_id ""
    price ""
    count ""
    order_id 1
  end
end
