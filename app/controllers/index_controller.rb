class IndexController < ApplicationController
  def index
    @products = Product.all
  end
end
