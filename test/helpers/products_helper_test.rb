require "test_helper"

describe ProductsHelper do
  let(:one) {products(:tree1)}
  let(:two) {products(:tree2)}

  describe "#product_description" do
    it "returns properly if the description exists" do
      product_description(one).must_equal "No description."
    end

    it "returns properly if the description is nil" do
      product_description(two).must_equal two.description
    end
  end
end
