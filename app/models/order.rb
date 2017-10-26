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

  validates :city,
    presence: {
      :if => lambda { self.status != "pending"}, message: "city cannot be blank"
    },
    format: {
      :if => lambda { self.status != "pending"},
      with:
      /\A(?:[a-zA-Z]+(?:[.'\-,])?\s?)+\z/i,
      message: "invalid city name"
    }

  validates :state,
    presence: {
      :if => lambda { self.status != "pending"}, message: "state cannot be blank"
    },
    format: {
      :if => lambda { self.status != "pending"},
      with:
      /\A(?:A[KLRZ]|C[AOT]|D[CE]|FL|GA|HI|I[ADLN]|K[SY]|LA|M[ADEINOST]|N[CDEHJMVY]|O[HKR]|PA|RI|S[CD]|T[NX]|UT|V[AT]|W[AIVY])*\z/,
      message: "invalid state abbreviation"
    }

  validates :zipcode,
    presence: {
      :if => lambda { self.status != "pending"}, message: "zipcode cannot be blank"
    },
    format: {
      :if => lambda { self.status != "pending"},
      with:
      /\A([0-9]{5}(?:-[0-9]{4})?)*\z/,
      message: "invalid zipcode"
    }

  validates :cc_name, presence: { :if => lambda { self.status != "pending"}, message: "name for credit card cannot be blank"}


  # https://gist.github.com/nerdsrescueme/1237767
  validates :cc_number,
    presence: {
      :if => lambda { self.status != "pending"}, message: "credit card number cannot be blank"
    },
    format: {
      :if => lambda { self.status != "pending"},
      with:
      /\A(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6011[0-9]{12}|3(?:0[0-5]|[68][0-9])[0-9]{11}|3[47][0-9]{13})\z/,
      message: "invalid credit card number"
    }

  validates :cc_expiration,
  expirationDate: true

  validates :cc_security,
    presence: {
      :if => lambda { self.status != "pending"}, message: "CVV cannot be blank"
    },
    format: {
      :if => lambda { self.status != "pending"},
      with:
      /\A[0-9]{3,4}\z/,
      message: "invalid CVV"
    }


  validates :billingzip,
    presence: {
      :if => lambda { self.status != "pending"}, message: "billing zipcode cannot be blank"
    },
    format: {
      :if => lambda { self.status != "pending"},
      with:
      /\A([0-9]{5}(?:-[0-9]{4})?)*\z/,
      message: "invalid billing zipcode"
    }

  def status_check
    return if self.status != "paid"
    unshipped = self.orderitems.select { |item| item.status != "shipped"}
    return if unshipped.length != 0
    self.status = "complete"
    self.save
  end

end
