class MerchantsController < ApplicationController
  before_action :find_merchant, only: [:show, :edit, :update, :destroy, :fulfillment, :show_order]
  before_action :account_owner?, only: [:show, :edit, :update, :destroy, :fulfillment, :show_order]

  def new
  end

  def show_order
    @order = Order.find_by(id: params[:order_id])
    if @order == nil
      flash[:status] = :error
      flash[:result_text] = "Invalid order"
      return redirect_back(fallback_location: root_path)
    end
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
        @orders[orderitem.order_id.to_s] = {status: orderitem.order.status, purchase_date: orderitem.order.purchase_datetime,revenue: new_revenue, items: new_items}
      end
      @total_revenue = orderitems.sum {|orderitem| ( (orderitem.order.status == "cancelled") ? 0 : (orderitem.quantity * orderitem.product.price) ) }
      @statuses = ["paid", "complete", "cancelled"]
      @revenue_by_status = {}
      @statuses.each do |a_status|
        @revenue_by_status[a_status] = orderitems.sum {|orderitem| orderitem.order.status == a_status ? (orderitem.quantity * orderitem.product.price) : 0}
      end
    else
      flash[:status] = :error
      flash[:result_text] = "Please log in first"
      redirect_to root_path
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
