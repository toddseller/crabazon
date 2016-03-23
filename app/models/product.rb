class Product < ActiveRecord::Base
	validates :name, :description, :price, :quantity, presence: true
  	belongs_to :user
  	scope :sort_by_price, -> { order(:price) }
end
