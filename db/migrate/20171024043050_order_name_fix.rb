class OrderNameFix < ActiveRecord::Migration[5.1]
  def change
    remove_column :products, :customer_name
    add_column :orders, :customer_name, :string
  end
end
