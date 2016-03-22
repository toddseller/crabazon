class User < ActiveRecord::Base
  has_many :products, foreign_key: "reseller_id"
end
