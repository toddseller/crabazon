class CategoriesController < ApplicationController

  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:success] = "Category successfully created!"
    else
      flash[:error] = "Opps! Something went wrong. Try again!"
      render 'new'
    end
  end

  def show
    @category = Category.find(params[:id])
    @products = @category.products
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      flash[:success] = "Category successfully updated!"
      redirect_to index_path
    else
      flash[:error] = "Opps! Something went wrong. Try again!"
      render 'edit'
    end
  end

  def destroy
    @category = Category.find(params[:id])
    if @category.destroy
      flash[:success] = "Category successfully updated!"
    end
  end

  private
  def category_params
    params.require(:category).permit(:name)
  end
end
