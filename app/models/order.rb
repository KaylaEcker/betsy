class Order < ApplicationRecord
  has_many :orderitems
  has_many :products, :through => :orderitems
  validates :status, presence: true

  def status_check
    unshipped = self.orderitems.select { |item| item.status != "shipped"}
    return if unshipped.length != 0
    self.status = "complete"
    self.save
  end

end
