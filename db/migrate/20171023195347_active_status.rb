class ActiveStatus < ActiveRecord::Migration[5.1]
  def change
    rename_column :products, :active, :active_status
  end
end
