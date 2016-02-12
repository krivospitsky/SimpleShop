# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delivery_method do
    name "MyString"
    description "MyText"
    hide "MyString"
    enabled false
    sort_order 1
    min_price 1
    max_price 1
  end
end
