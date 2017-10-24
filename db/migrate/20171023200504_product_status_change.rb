class ProductStatusChange < ActiveRecord::Migration[5.1]
  def change
    remove_column :products, :active_status
    add_column :products, :status, :string
  end
end
