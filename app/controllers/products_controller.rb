class ProductsController < ApplicationController
  def index
    @products = Product.sort_by_price
  end

  def new
    @product = Product.new
    @categories = Category.all
  end

  def create
    @product = Product.new(product_params)
    @categories_id = params[:category_ids]
    if @product.save
      @categories_id.each do |category_id|
        category = Category.find(category_id)
        @product.categories << category
      end
      flash[:success] = "Product successfully created!"
      redirect_to "/admin"
    else
      flash[:error] = "Opps! Something went wrong. Try again!"
      render 'new'
    end
  end

  def show
    @product = Product.find(params[:id])
    render 'show'
  end

  def edit
    @product = Product.find(params[:id])
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
    params.require(:product).permit(:name, :description, :price, :quantity, :product_image, { categories: [] })
  end

end
