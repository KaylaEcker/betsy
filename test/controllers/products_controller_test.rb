require "test_helper"

describe ProductsController do
  let(:one) {products(:tree1)}

  describe "index" do
    it "must get the index view" do
      get products_path
      must_respond_with :success
    end

    it "must respond with success with valid filter parameters" do
      #valid category
      get products_path, params: {categories: one.categories}
      must_respond_with :success
      #valid merchant
      get products_path, params: {merchant: one.merchant.id}
      must_respond_with :success
      #valid category and merchant
      get products_path, params: {categories: one.categories, merchant: one.merchant.id}
      must_respond_with :success
    end

    it "must respond with a 404 (400?) if any filter parameters are invalid" do
      skip
    end
  end

  it "must get the show view" do
    get product_path(one.id)
    must_respond_with :success

    get product_path(-1)
    must_respond_with :redirect
    must_redirect_to root_path
  end

  it "should get new" do
    @merchant = merchants(:sappy1)
    login(@merchant, :github)
    get new_product_path
    must_respond_with :success
  end

  it "should be able to successfully create a new product" do
    category_count = Product.pluck(:category).uniq
    puts "================="
    puts category_count.inspect
    puts "================="
    @merchant = merchants(:sappy1)
    login(@merchant, :github)
      proc {
        post products_path, params: { product: { name: "newbie", price: 2, category: "new category", quantity: 1, merchant_id: merchants(:sappy1).id } }
      }.must_change 'Product.count', 1
      must_respond_with :redirect
      updated_category_count = Product.pluck(:category).uniq
      updated_category_count.count.must_equal (category_count.count + 1)
    end
    it "should rerender the form and not update the review table if it can't create the review" do
      @merchant = merchants(:sappy1)
      login(@merchant, :github)
      proc {
        post products_path, params: { product: { name: "", price: 2, category: "new category", quantity: 1, merchant_id: merchants(:sappy1).id } }
      }.must_change 'Review.count', 0

      must_respond_with :redirect
    end


  describe "edit" do

    let(:one) {products(:tree1)}
    let(:two) {products(:tree2)}

    it "must redirect to root path if there is no product" do
      get edit_product_path(-1)
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "must redirect to root path if the merchant of the product is not signed in" do
      # With no mercant signed in
      get edit_product_path(one.id)
      must_respond_with :redirect
      must_redirect_to root_path

      #With an invalid merchant signed in
      invalid_merchant = merchants(:sappy2)
      login(invalid_merchant, :github)

      get edit_product_path(one.id)
      flash[:status].must_equal :error
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "must render to edit view if the merchant is logged in and there is a product" do
      @merchant = merchants(:sappy1)
      login(@merchant, :github)

      get edit_product_path(one.id)
      must_respond_with :success
    end

  end

  describe "update" do
    let(:one) {products(:tree1)}
    let(:merchant1) {merchants(:sappy1)}
    let(:merchant2) {merchants(:sappy2)}

    it "will redirect if the product is invalid" do
      patch product_path(-1), params: { categories: ["Birthday"] }
      flash[:status].must_equal :error
      flash[:result_text].must_equal "That is not a valid product"
      must_redirect_to root_path
    end

    it "will not save and will redirect if the merchant of the product is not signed in" do
      #no merchant signed in
      categories = one.categories

      patch product_path(one.id), params:{categories: ["Birthday"]}
      flash[:status].must_equal :error
      must_redirect_to root_path

      one.categories.must_equal categories

      #Invalid merchant is signed in
      login(merchant2, :github)

      patch product_path(one.id), params:{categories: ["Birthday"]}
      flash[:status].must_equal :error
      must_redirect_to root_path

      one.categories.must_equal categories

    end

    it "must successfully updates the categories if the merchant is signed in" do
      login(merchant1, :github)

      session[:merchant_id].to_i.must_equal merchant1.id

      #format passed through params if chosen from a list
      before = one.categories.count
      patch product_path(one.id), params:{ categories: ["outdoor"]}

      test_product = Product.find_by(id: one.id)

      test_product.categories.length.must_equal (before + 1)
      test_product.categories.must_include "outdoor"

      #format passed through params if typed in
      before = one.categories.count
      patch product_path(one.id), params:{ category: "Birthday"}

      test_product = Product.find_by(id: one.id)

      # test_product.categories.count.must_equal before + 1
      test_product.categories.must_include "Birthday"
    end

    it "must return succes and redirect to root_path if saved" do
      login(merchant1, :github)

      session[:merchant_id].to_i.must_equal merchant1.id

      patch product_path(one.id), params:{ categories: ["outdoor"]}

      flash[:status].must_equal :success
      must_redirect_to product_path(one.id)
    end
  end
end
