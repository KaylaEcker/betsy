class Order < ApplicationRecord
  has_many :orderitems
  has_many :products, :through => :orderitems
  validates :status, presence: true

  validates :customer_name, presence: { :if => lambda { self.status != "pending"}, message: "name cannot be blank"}

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

  validates :city, presence: { :if => lambda { self.status != "pending"}, message: "city cannot be blank"}

  validates :state, presence: { :if => lambda { self.status != "pending"}, message: "state cannot be blank"}

  validates :zipcode, presence: { :if => lambda { self.status != "pending"}, message: "zipcode cannot be blank"}

  validates :cc_name, presence: { :if => lambda { self.status != "pending"}, message: "name for credit card cannot be blank"}

  validates :cc_number, presence: { :if => lambda { self.status != "pending"}, message: "credit card number cannot be blank"}

  validates :cc_expiration, presence: { :if => lambda { self.status != "pending"}, message: "credit card expiration date cannot be blank"}

  validates :cc_security, presence: { :if => lambda { self.status != "pending"}, message: "CVV cannot be blank"}

  validates :billingzip, presence: { :if => lambda { self.status != "pending"}, message: "billing zipcode cannot be blank"}
end
