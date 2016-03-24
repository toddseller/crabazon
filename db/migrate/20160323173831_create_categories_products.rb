class CreateCategoriesProducts < ActiveRecord::Migration
  def change
    create_table :categories_products do |t|
      t.belongs_to :product, index: true
      t.belongs_to :category, index: true

      t.timestamps null: false
    end
  end
end
