class AdminController < ApplicationController
	before_action :authenticate_admin!

	def index
		@products = Product.sort_by_price
	end
end



