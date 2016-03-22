class ProductsController < ApplicationController
  def index
    @products = Product.sort_by_price
  end

  def new
    @product = Product.new
  end

  def edit
    @product = Product.find(params[:id])
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      flash[:success] = "Product successfully saved!"
      redirect_to "/admin"
    else
      render 'new'
    end
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to "/"
    else
      render 'edit'
    end
  end

  private
  def product_params
    params.require(:product).permit(:name, :description, :price, :quantity, :product_image)
  end

end
