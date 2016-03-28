class AddOrdersColumnOrderDate < ActiveRecord::Migration
  def change
    add_column :orders, :order_date, :datetime
  end
end
