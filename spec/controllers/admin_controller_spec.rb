require 'rails_helper'
require_relative '../support/auth_helper'



RSpec.describe AdminController, type: :controller do render_views
	include AuthHelper
  	before(:each) do
    	http_login
  	end

 	it 'assigns all product to @products by price' do 
      get :index
      expect(assigns(:products)).to eq(Product.sort_by_price)
    end

	describe 'index page has all products' do 
		it "should load all the client's products" do 
			get :index
			expect(response).to render_template(:index)
		end
	end
end

RSpec.describe AdminController, type: :controller do render_views
	include AuthHelper
  	before(:each) do
    	http_login_fail
  	end

  	it 'doesnt assigns all product to @products by price' do 
      get :index
      expect(assigns(:products)).not_to eq(Product.sort_by_price)
    end

	describe 'index page has all products' do 
		it "should load all the client's products" do 
			get :index
			expect(response).not_to render_template(:index)
		end
	end

 end