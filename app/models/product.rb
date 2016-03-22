class Product < ActiveRecord::Base
  belongs_to :user

  validates :name, :description, :price, :quantity, presence: true

  scope :sort_by_price, -> { order(:price) }

end
