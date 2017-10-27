class ProductsController < ApplicationController
before_action :find_product, only: [:show, :edit, :update, :retire]
before_action :find_merchant, except: [:index, :destroy]
before_action :get_categories, only: [:index, :edit, :new]

  def index

    unless @merchant
      merchant = params[:merchant]
    end

    unless @category
      category = params[:category]
    end

    @products = (Product.get_products(a_category: category, a_merchant: merchant) & Product.active_only).paginate(page: params[:page], per_page: 15)

    # IF NEEDED UNCOMMENT self.retired_only IN MODEL
    # @retired_products = Product.get_products(a_category: params[:category], a_merchant: params[:merchant]) & Product.retired_only

    # UNCOMMENT IF NEEDED
    # @all_products = Product.get_products(a_category: params[:category], a_merchant: params[:merchant])
  end

  def show
    unless @merchant == @product.merchant
      render_404 if @product.status == "retired"
    end
    @title = @product.name
  end

  def edit
    unless @merchant == @product.merchant
      flash[:status] = :error
      flash[:result_text] = "Unauthorized user"
      return redirect_to root_path
    end
    @title = "Edit #{@product.name}"
  end

  def update
    unless @merchant == @product.merchant
      flash[:status] = :error
      flash[:result_text] = "Unauthorized user"
      return redirect_to root_path
    end
    @product.update_attributes(product_params)
    update_categories

    if @product.save
      flash[:status] = :success
      flash[:result_text] = "#{@product.name} updated."
      redirect_to product_path(@product.id)
    else
      @categories = @product.categories
      flash.now[:status] = :error
      flash.now[:result_text] = "Could not update product"
      flash.now[:messages] = @product.errors.messages
      render :edit, status: 400
    end
  end

  def new
    unless @merchant
      flash[:status] = :error
      flash[:result_text] = "You need to be logged in to create a product!"
      redirect_back fallback_location: root_path
    end

    @product = Product.new(merchant_id: session[:merchant_id])
    @title = "New Product"
  end

  def create
    unless @merchant
      flash[:status] = :error
      flash[:result_text] = "You need to be logged in to create a product!"
      return redirect_back fallback_location: root_path
    end

    @product = Product.new(product_params)

    update_categories

    if @product.save
      return redirect_to product_path(@product.id)
    else
      @categories = @product.categories
      flash.now[:status] = :error
      flash.now[:result_text] = "Product failed to be added"
      flash.now[:messages] = @product.errors.messages
      render :new, status: 400
    end
  end

  def retire
    unless @merchant == @product.merchant
      flash[:status] = :error
      flash[:result_text] = "Unauthorized user"
      return redirect_to root_path
    end
    @product.status == "active" ? @product.status = "retired" : @product.status = "active"
    if @product.save
      flash[:status] = :success
      flash[:result_text] = "Product status was updated to #{@product.status}."
    else
      flash[:status] = :error
      flash[:result_text] = "Product status couldn't be updated."
      flash[:messages] = @product.errors.messages
    end
    return redirect_back fallback_location: root_path
  end

  private

  def find_product
    @product = Product.find_by_id(params[:id])
    render_404 unless @product
  end

  def product_params
    return params.permit(:name, :price, :merchant_id, :quantity, :description, :photo_url, :status)
  end

  def find_merchant
    @merchant = Merchant.find_by(id: session[:merchant_id])
  end

  def get_categories
    @categories = Product.categories
  end

  def update_categories
    if params[:categories]
      params[:categories].each do |category|
        @product.add_category(category)
      end
    end

    if params[:category]
      @product.add_category(params[:category])
    end
  end
end
