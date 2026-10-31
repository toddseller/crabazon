class CategoriesController < ApplicationController
  before_action :authenticate_admin!, except: [:show]

  def index
    @categories = Category.sort_by_name
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:success] = "Category successfully created!"
      redirect_to categories_path
    else
      flash.now[:error] = "Opps! Something went wrong. Try again!"
      render 'new'
    end
  end

  def show
    @category = Category.find(params[:id])
    @products = @category.products.sort_by_price
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      flash[:success] = "Category successfully updated!"
      redirect_to categories_path
    else
      flash.now[:error] = "Opps! Something went wrong. Try again!"
      render 'edit'
    end
  end

  def destroy
    Category.find(params[:id]).destroy
    flash[:success] = "Category successfully deleted!"
    redirect_to categories_path
  end

  private
  def category_params
    params.require(:category).permit(:name)
  end
end
