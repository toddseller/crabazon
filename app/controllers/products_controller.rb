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
      flash[:success] = "Product successfully created!"
      redirect_to "/admin"
    else
      flash[:error] = @product.errors.full_messages.to_sentence
      render 'new'
    end
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      flash[:success] = "Product successfully updated!"
      redirect_to "/admin"
    else
      render 'edit'
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    flash[:success] = "Product successfully deleted!"
    redirect_to '/admin'
  end

  private
  def product_params
    params.require(:product).permit(:name, :description, :price, :quantity, :product_image)
  end

end
