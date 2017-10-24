require "test_helper"

describe Order do
  let(:one) { orders(:one) }
  let(:two) { orders(:two) }

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
