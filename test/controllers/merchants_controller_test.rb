require "test_helper"

describe MerchantsController do
  let(:merchant) {merchants(:sappy1)}
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
      flash[:result_text].must_equal "Please log in first"
    end

    it "redirects to the homepage when the merchant does not exist" do
      get merchant_fulfillment_path(-1)
      must_respond_with :redirect
      flash[:result_text].must_equal "Please log in first"
    end
  end
end
