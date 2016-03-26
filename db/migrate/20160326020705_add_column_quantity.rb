class AddColumnQuantity < ActiveRecord::Migration
  def change
  	add_column :orders_products, :quantity, :integer
  end
end
