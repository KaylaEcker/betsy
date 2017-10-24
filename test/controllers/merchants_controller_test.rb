require "test_helper"

describe MerchantsController do
  let(:merchant) {merchants(:sappy1)}
  let(:other_merchant) {merchants(:sappy2)}

  describe "#fulfillment" do
    it "gets the fulfillment page with a valid merchant logged in" do
      login(merchant, merchant.oauth_provider.to_sym)
      session[:merchant_id].to_i.must_equal merchant.id
      get merchant_fulfillment_path(merchant.id)
      must_respond_with :success
    end
    it "redirects to the homepage when the merchant is not logged in" do
      get merchant_fulfillment_path(merchant.id)
      must_respond_with :redirect
      flash[:result_text].must_equal "Unauthorized user"
    end

    it "redirects to the homepage when the merchant does not exist" do
      get merchant_fulfillment_path(-1)
      must_respond_with :redirect
      flash[:result_text].must_equal "Invalid request"
    end
  end

  describe "logged in merchants" do

    it "merchants can access their own account page" do
        login(merchant, :github)
        flash[:success].must_equal "sappy1 is logged in!"
        get merchant_path(merchant.id)
        must_respond_with :success
    end

    it "merchants can't access other merchants account page" do
        login(merchant, :github)
        flash[:success].must_equal "sappy1 is logged in!"
        get merchant_path(other_merchant.id)
        flash[:status].must_equal :error
        flash[:result_text].must_equal "Unauthorized user"
    end

  end

  describe "guests" do

    it "guest can't access any account/merchant page" do
        get merchant_path(merchant.id)
        flash[:status].must_equal :error
        flash[:result_text].must_equal "Unauthorized user"
        get merchant_path(other_merchant.id)
        flash[:status].must_equal :error
        flash[:result_text].must_equal "Unauthorized user"
    end

  end
end
