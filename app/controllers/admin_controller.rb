class AdminController < ApplicationController
	  before_action :authenticate_user!
	def index
		@products = Product.sort_by_price
	end
end



