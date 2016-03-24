class Category < ActiveRecord::Base
  has_and_belongs_to_many :products

  scope :sort_by_name, -> { order(:name) }
end
