class Order < ApplicationRecord
  has_many :orderitems
  has_many :products, :through => :orderitems
  validates :status, presence: true

  def self.statuses
    return Order.pluck(:status).flatten.uniq
  end

end
