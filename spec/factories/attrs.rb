# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attr do
    name "MyString"
    value "MyString"
    variantable false
    product_id 1
  end
end
