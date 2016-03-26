class CreateOrdersProducts < ActiveRecord::Migration
  def change
    create_table :orders_products do |t|
    	t.belongs_to :product, index: true
      	t.belongs_to :order, index: true

      	t.timestamps null: false
    end
  end
end
