class MerchantsController < ApplicationController
  def new
  end

  def fulfillment
    @merchant = Merchant.find_by(id: params[:id])
    orderitems = @merchant.join_orderitems
    @orders = {}
    orderitems.each do |orderitem|
      if @orders[orderitem.order_id.to_s] == nil
        new_revenue = orderitem.quantity * orderitem.product.price
        new_items = [orderitem]
      else
        new_revenue = @orders[orderitem.order_id.to_s][:revenue] + (orderitem.quantity * orderitem.product.price)
        new_items = @orders[orderitem.order_id.to_s][:items]
        new_items << orderitem
      end
      @orders[orderitem.order_id.to_s] = {status: orderitem.order.status, purchase_date: orderitem.order.purchase_datetime,revenue: new_revenue, items: new_items}
      # @orders[orderitem.order_id.to_s][:revenue] += (orderitem.product.price * orderitem.quantity)
    end
    #all the unique order ids from @orderitems
    #idea: make a hash with the order_id as the key and the revenue as the value
  end

  def create
  end

  def index
  end

  def edit
  end

  def update
  end

  def show
  end
end
