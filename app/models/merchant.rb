class Merchant < ApplicationRecord
  has_many :products

  validates :username, presence: true
  validates :username, uniqueness: true
  validates :email, presence: true
  validates :email, uniqueness: true

  def join_orderitems(status)
    if [nil, ""].include?(status)
      return Orderitem.joins('join products on orderitems.product_id = products.id').where("products.merchant_id = #{self.id}").joins('LEFT JOIN orders ON orderitems.order_id = orders.id').where("orders.status IS DISTINCT FROM 'pending'")
    else
      return Orderitem.joins('join products on orderitems.product_id = products.id').where("products.merchant_id = #{self.id}").joins('LEFT JOIN orders ON orderitems.order_id = orders.id').where("orders.status = '#{status}' AND orders.status IS DISTINCT FROM 'pending'")
    end
  end

  def self.active_merchants
    products = Product.where(status: "active").pluck(:merchant_id).uniq
    merchants = products.map { |m| Merchant.find_by(id: m) }
    return merchants.sort_by{|m| m.username.downcase}
  end

end
