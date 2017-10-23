class MerchantsController < ApplicationController
  def new
  end

  def fulfillment
    @merchant = Merchant.find_by(id: params[:id])
    status = params[:status]
    orderitems = @merchant.join_orderitems(status)
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
    end

    @statuses = Product.statuses
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
