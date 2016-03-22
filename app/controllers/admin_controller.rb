class AdminController < ApplicationController
	  http_basic_authenticate_with name: "admin", password: "secret"
	def index
		@products = Product.all
	end
end



