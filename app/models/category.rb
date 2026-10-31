class Category < ActiveRecord::Base
  has_and_belongs_to_many :products

  normalizes :name, with: ->(name) { name.strip.downcase }
  validates :name, presence: true, uniqueness: true

  scope :sort_by_name, -> { order(:name) }
end
