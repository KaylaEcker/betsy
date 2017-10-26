require "test_helper"

describe Order do
  let(:one) { orders(:one) }
  let(:two) { orders(:two) }

  describe "validations" do
    let(:one) { orders(:one) }
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
    it "can have nil values if the status of the order is pending" do
      order = Order.new(status: "pending")
      order.valid?.must_equal true
    end

    it "must have customer_name" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false

      order.errors.messages.must_include :customer_name
      order.errors.messages[:customer_name].must_include "name cannot be blank"
    end

    it "must have customer_email" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false
      order.errors.messages.must_include :customer_email
      order.errors.messages[:customer_email].must_include "customer email cannot be blank"
    end

    it "must have a valid email address" do
      order = Order.new(status: "paid", customer_email: "yahoo")
      order.valid?.must_equal false
      order.errors.messages.must_include :customer_email
      order.errors.messages[:customer_email].must_include "invalid email format"
    end

    it "will accept a valid email address" do
      order = Order.new(status: "paid", customer_email: "cool@yahoo.com")

      order.valid?.must_equal false
      order.errors.messages.wont_include :customer_email
    end

    it "must have an address if the status of the order is not pending" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false

      order.errors.messages.must_include :address1
      order.errors.messages[:address1].must_include "address cannot be blank"
    end

    it "must have a city" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false

      order.errors.messages.must_include :city
      order.errors.messages[:city].must_include "city cannot be blank"
    end

    it "must have a valid city name" do
      order = Order.new(status: "paid", city: "Too---long")
      order.valid?.must_equal false
      order.errors.messages.must_include :city
      order.errors.messages[:city].must_include "invalid city name"
    end

    it "must have have a state" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false

      order.errors.messages.must_include :state
      order.errors.messages[:state].must_include "state cannot be blank"
    end

    it "must have a valid state code" do
      order = Order.new(status: "paid", state: "PK")
      order.valid?.must_equal false
      order.errors.messages.must_include :state
      order.errors.messages[:state].must_include "invalid state abbreviation"
    end

    it "must have a zipcode" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false
      order.errors.messages.must_include :zipcode
      order.errors.messages[:zipcode].must_include "zipcode cannot be blank"
    end

    it "must have a valid US zipcode" do
      order = Order.new(status: "paid", zipcode: "ABCDE")
      order.valid?.must_equal false
      order.errors.messages.must_include :zipcode
      order.errors.messages[:zipcode].must_include "invalid zipcode"
    end

    it "must have a cc_name" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false

      order.errors.messages.must_include :cc_name
      order.errors.messages[:cc_name].must_include "name for credit card cannot be blank"
    end

    it "must have a cc_number" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false

      order.errors.messages.must_include :cc_number
      order.errors.messages[:cc_number].must_include "credit card number cannot be blank"
    end

    it "must have a valid cc_number" do
      order = Order.new(status: "paid", cc_number: 123456789)
      order.valid?.must_equal false
      order.errors.messages.must_include :cc_number
      order.errors.messages[:cc_number].must_include "invalid credit card number"
    end

    it "must have a cc_expiration" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false

      order.errors.messages.must_include :cc_expiration
      order.errors.messages[:cc_expiration].must_include "expiration date can\'t be blank"
    end

    it "must have a valid expiration date format" do

      order = Order.new(status: "paid", cc_expiration: "13/2000" )
      order.valid?.must_equal false

      order.errors.messages.must_include :cc_expiration
      order.errors.messages[:cc_expiration].must_include "invalid expiration date format"
    end

    it "can't have an expiration date in the past" do
      order = Order.new(status: "paid", cc_expiration: "11/16" )
      order.valid?.must_equal false

      order.errors.messages.must_include :cc_expiration

      order.errors.messages[:cc_expiration].must_include "expiration date can\'t be in the past"
    end

    it "can have an expiration date in the future" do
      order = Order.new(status: "paid", cc_expiration: "12/17" )
      order.valid?.must_equal false
      order.errors.messages.wont_include :cc_expiration
      order.errors.messages[:cc_expiration].wont_include "expiration date can\'t be in the past"
    end

    it "must have a cc_security" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false

      order.errors.messages.must_include :cc_security
      order.errors.messages[:cc_security].must_include "CVV cannot be blank"
    end

    it "must have a valid (format) CVV security" do
      order = Order.new(status: "paid", cc_security: "ABC")
      order.valid?.must_equal false
      order.errors.messages.must_include :cc_security
      order.errors.messages[:cc_security].must_include "invalid CVV"
    end

    it "must have a billingzip" do
      order = Order.new(status: "paid" )
      order.valid?.must_equal false

      order.errors.messages.must_include :billingzip
      order.errors.messages[:billingzip].must_include "billing zipcode cannot be blank"
    end

    it "must have a valid US billing zipcode" do
      order = Order.new(status: "paid", billingzip: "ABCDE")
      order.valid?.must_equal false
      order.errors.messages.must_include :billingzip
      order.errors.messages[:billingzip].must_include "invalid billing zipcode"
    end
  end

  describe "#status_check" do
    it "will change the status of an order from 'paid' to 'complete' if all items are shipped" do
      one.status.must_equal "paid"
      one.orderitems.each do |item|
        item.status.wont_equal "shipped"
        item.status = "shipped"
        item.save.must_equal true
        one.status.must_equal "paid"
      end
      one.status_check
      one.status.must_equal "complete"
    end

    it "won't change the status of an order if all items still need to be shipped" do
      one.status.must_equal "paid"
      one.orderitems.each do |item|
        item.status.wont_equal "shipped"
      end
      one.status_check
      one.status.must_equal "paid"
    end

    it "won't change the status of an order is some items still need to be shipped" do
      one.status.must_equal "paid"
      one.orderitems.first do |item|
        item.status.wont_equal "shipped"
        item.status = "shipped"
        item.save.must_equal true
        one.status.must_equal "paid"
      end
      one.status_check
      one.status.must_equal "paid"
    end

    it "won't change the status of an order that is already complete" do
      two.status.must_equal "complete"
      two.status_check
      two.status.must_equal "complete"
    end
  end
end
