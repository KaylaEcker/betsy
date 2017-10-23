class Order < ApplicationRecord
  has_many :orderitems
  has_many :products, :through => :orderitems
  validates :status, presence: true

  validates :customer_email,
    presence: {
      :if => lambda { self.status != "pending"},
      message: "customer email cannot be blank"
    },
    format: {
      :if => lambda { self.status != "pending"},
      with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i,
      message: "invalid email format"
    }

  validates :address1, presence: { :if => lambda { self.status != "pending"}, message: "address cannot be blank"}

end
