class Product < ActiveRecord::Base
	validates :name, :description, :price, :quantity, presence: true
  	belongs_to :user

  	validates :name, :description, :price, :quantity, presence: true

  	scope :sort_by_price, -> { order(:price) }

end
