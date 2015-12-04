# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :slide do
    name "MyString"
    enabled false
    image "MyString"
    url "MyString"
    start_at "2015-12-04"
    end_at "2015-12-04"
  end
end
