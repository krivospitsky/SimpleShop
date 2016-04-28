#coding:utf-8
class Order < ActiveRecord::Base
  belongs_to :cart

  # has_many :cart_items, foreign_key: :cart_id, primary_key: :cart_id
  has_many :order_items
  accepts_nested_attributes_for :order_items, allow_destroy:true

  belongs_to :delivery_method
  belongs_to :payment_method

  # validates :name, presence: true
  validates :email, presence: true
  validates :phone, presence: true
  validates :name, presence: true
  validates :delivery_method, presence: true
  validates :payment_method, presence: true

  # state_machine :state, :initial => :Новый do
  #   event :processing do
  #     transition :Новый => :Обработка
  #   end
  #   event :processed do
  #     transition :Обработка => :Выполнен
  #   end
  #   event :reject do
  #     transition any - :Отменен => :Отменен
  #   end
  # end

  # def discount_value

  # end

  def price
    total=0
    order_items.each do |item|
      if item.discount_price
        total+=item.discount_price*item.quantity
      else
        total+=item.price*item.quantity
      end
    end
    total
  end

  def discount_value
    price*discount/100
  end

  def total_price    
    price - discount_value + (delivery_method.price || 0)
  end

  def total_price_str
    "#{total_price} руб."
  end


  before_save :set_secure_key
  def set_secure_key
    self.secure_key ||= SecureRandom.hex(16)
  end
end
