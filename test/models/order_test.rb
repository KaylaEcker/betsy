require "test_helper"

describe Order do
  let(:one) { orders(:one) }

  describe "validations" do
    it "must have one or more order items" do
      one.orderitems.each do |o|
        o.must_be_kind_of Orderitem
      end
    end

    it "can access products in the order" do
      one.products.each do |o|
        o.must_be_kind_of Product
      end
    end
  end

  describe "checkout validations" do
    let(:pend_cust) {orders( :pending_customer) }

    it "can have nil values if the status of the order is pending" do
      order = Order.new(status: "pending")
      order.valid?.must_equal true
    end

    it "must have email if the status of the order is not pending" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false
      order.errors.messages.must_include :customer_email
      order.errors.messages[:customer_email].must_include "customer email cannot be blank"
    end

    it "must have an address if the status of the order is not pending" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false

      order.errors.messages.must_include :address1
      order.errors.messages[:address1].must_include "address cannot be blank"
    end





  end

end
