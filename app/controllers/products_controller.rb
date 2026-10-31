class ProductsController < ApplicationController
  before_action :authenticate_admin!, except: [:index, :show]

  def index
    @products = Product.sort_by_price
  end

  def new
    @product = Product.new
    @categories = Category.sort_by_name
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      flash[:success] = "Product successfully created!"
      redirect_to "/admin"
    else
      flash.now[:error] = "Opps! Something went wrong. Try again!"
      render 'new'
    end
  end

  def show
    @product = Product.find(params[:id])
    render 'show'
  end

  def edit
    @product = Product.find(params[:id])
    @categories = Category.sort_by_name
    @product.categories.pluck(:id)
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      flash[:success] = "Product successfully updated!"
      redirect_to "/admin"
    else
      flash.now[:error] = "Opps! Something went wrong. Try again!"
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
    # The category checkboxes sit outside the product form, and send nothing when none is ticked.
    params.require(:product).permit(:name, :description, :price, :quantity, :product_image).merge(category_ids: params[:category_ids] || [])
  end

end
