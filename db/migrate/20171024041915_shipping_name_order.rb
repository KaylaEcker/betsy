class ShippingNameOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :customer_name, :string
  end
end
