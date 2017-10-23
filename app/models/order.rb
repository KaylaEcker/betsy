class Order < ApplicationRecord
  has_many :orderitems
  has_many :products, :through => :orderitems
  validates :status, presence: true

  #checkout validations
  validates :customer_email, presence: { :if => lambda { self.status != "pending"}, message: "customer email cannot be blank"}

  validates :address1, presence: { :if => lambda { self.status != "pending"}, message: "address cannot be blank"}


end
