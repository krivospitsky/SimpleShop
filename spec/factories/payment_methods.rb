# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_method do
    name "MyString"
    description "MyText"
    hide "MyString"
    enabled false
    sort_order 1
    use_online false
  end
end
