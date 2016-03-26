class RemoveReseller < ActiveRecord::Migration
  def change
  	remove_column :products, :reseller_id, :integer
  end
end
