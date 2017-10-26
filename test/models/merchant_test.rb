require "test_helper"
  #needs to write in two tests for scopes on the model

describe Merchant do
  let(:merchant) { Merchant.new }
  let(:sappy1) { merchants(:sappy1) }
  let(:product) { products(:tree1) }

  it "must have a username" do
    sappy1.valid?.must_equal true
    sappy1.username = nil
    sappy1.valid?.must_equal false
    sappy1.save
    sappy1.errors.keys.must_include :username
  end

  it "must have a unique username" do
    sappy1.username = "sappy2"
    sappy1.valid?.must_equal false
  end

  it "must have an email address" do
    sappy1.valid?.must_equal true
    sappy1.email = nil
    sappy1.valid?.must_equal false
    sappy1.save
    sappy1.errors.keys.must_include :email
  end

  it "must have a unique email" do
    sappy1.email = "sappy2@gmail.com"
    sappy1.valid?.must_equal false
  end

  it "must return the products of the merchant" do
    sappy1.products.must_be_kind_of Enumerable
    sappy1.products.each do |product|
      product.must_be_kind_of Product
    end
  end

  describe "#join_orderitems(status)" do
    it "won't return any pending orders, even if pending is the specified status filter" do
      # verify that sappy1 has a pending order
      pending_orders = Order.where(status: "pending")
      merchant_pending_orders = 0
      pending_orders.each do |order|
        order.orderitems.each do |item|
          merchant_pending_orders += 1 if item.product.merchant_id == sappy1.id
        end
      end
      # verify that the pending order won't show up in the collection returned by join_orderitems(status)
      merchant_pending_orders.must_be :>, 0
      all_order_items = sappy1.join_orderitems("")
      all_order_items.length.must_equal 4
      all_order_items.each do |item|
        item.order.status.wont_equal "pending"
      end
      sappy1.join_orderitems("pending").length.must_equal 0
    end

    it "returns all orders when a status is an empty string or nil" do
      sappy1_orderitems = sappy1.join_orderitems("")
      sappy1_orderitems.length.must_equal 4
      sappy1.join_orderitems(nil).must_equal sappy1_orderitems
    end

    it "returns filtered orders by status when status is an appropriate value" do
      ["paid", "cancelled"].each do |status|
        sappy1_orderitems = sappy1.join_orderitems(status)
        sappy1_orderitems.each do |item|
          item.order.status.must_equal status
        end
      end
    end
  end

  describe "active merchants" do


    it "returns a uniq array of active merchants" do
      merchants = Merchant.active_merchants
      merchants.must_be_kind_of Array
      merchants.each do |m|
        m.must_be_instance_of Merchant
      end

      merchants.uniq.must_equal merchants
    end

    it "will include merchants that have both retired and active products" do
      Merchant.active_merchants.must_include merchants(:sappy1)
    end

    it "will return an empty arrray if no merchants have any products" do
      Orderitem.all.destroy_all
      Review.all.destroy_all
      Product.all.destroy_all

      Merchant.active_merchants.must_be_kind_of Array
      Merchant.active_merchants.length.must_equal 0
    end

    it "will return an empty array if no merchants have any active products" do
      Product.all.each do |p|
        p.status = "retired"
        p.save
      end

      Merchant.active_merchants.must_be_instance_of Array
      Merchant.active_merchants.length.must_equal 0
    end

  end


end #describe merchant
