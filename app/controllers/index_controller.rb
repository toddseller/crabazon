class IndexController < ApplicationController
  def index
    @products = Product.sort_by_price
  end
end
