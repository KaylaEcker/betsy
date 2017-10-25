class MerchantsController < ApplicationController
  before_action :find_merchant, only: [:show, :edit, :update, :destroy, :fulfillment, :show_order, :ship_orderitems]
  before_action :account_owner?, only: [:show, :edit, :update, :destroy, :fulfillment, :show_order, :ship_orderitems]

  def new
  end

  def show_order
    @order = Order.find_by(id: params[:order_id])
    if @order == nil
      flash[:status] = :error
      flash[:result_text] = "Invalid order"
      return redirect_back(fallback_location: root_path)
    end
    @title = "Review Order #{@order.id}"
    @orderitems = @order.orderitems.select { |item| item.product.merchant_id == @merchant.id }
    @unshipped = (@orderitems.select { |item| item.status != "shipped"}.length >0 )
  end

  def fulfillment
    if params[:id].to_i == session[:merchant_id]
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
        @orders[orderitem.order_id.to_s] = {status: orderitem.order.status, purchase_date: orderitem.order.purchase_datetime,revenue: new_revenue, items: new_items, unshipped: ""}
      end
      @orders.each do |order_id, hash|
        unshipped = hash[:items].select { |item| item.status != "shipped"}.length > 0
        @orders[order_id][:unshipped] = unshipped
      end
      @total_revenue = orderitems.sum {|orderitem| ( (orderitem.order.status == "cancelled") ? 0 : (orderitem.quantity * orderitem.product.price) ) }
      @statuses = ["paid", "complete", "cancelled"]
      @revenue_by_status = {}
      @statuses.each do |a_status|
        @revenue_by_status[a_status] = orderitems.sum {|orderitem| orderitem.order.status == a_status ? (orderitem.quantity * orderitem.product.price) : 0}
      end
      @title = "Fulfillment"
    else
      flash[:status] = :error
      flash[:result_text] = "Please log in first"
      redirect_to root_path
    end
  end

  def ship_orderitems
    order = Order.find_by(id: params[:order_id].to_i)
    orderitems = order.orderitems.select { |item| item.product.merchant_id == @merchant.id }
    if orderitems.length < 1
      flash[:status] = :error
      flash[:result_text] = "Invalid order"
      return redirect_back(fallback_location: root_path)
    end
    saveditems = 0
    orderitems.each do |item|
      item.status = "shipped"
      saveditems +=1 if item.save
    end
    order.status_check
    if saveditems == orderitems.length
      flash[:status] = :success
      flash[:result_text] = "Order marked as shipped"
      return redirect_back(fallback_location: merchant_fulfillment_path(@merchant.id))
    else
      flash[:status] = :error
      flash[:result_text] = "Order could not be marked as shipped"
      redirect_back(fallback_location: root_path)
    end
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
    @title = "My Account"
  end

  private

  def find_merchant
    @merchant = Merchant.find_by_id(params[:id])
    unless @merchant
      flash[:status] = :error
      flash[:result_text] = "Invalid request"
      return redirect_back fallback_location: root_path
    end
  end

  def account_owner?
    if session[:merchant_id] != @merchant.id
      flash[:status] = :error
      flash[:result_text] = "Unauthorized user"
      return redirect_back fallback_location: root_path
    end
  end

end
