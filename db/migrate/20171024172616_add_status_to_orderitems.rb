class AddStatusToOrderitems < ActiveRecord::Migration[5.1]
  def change
    add_column :orderitems, :status, :string
  end
end
