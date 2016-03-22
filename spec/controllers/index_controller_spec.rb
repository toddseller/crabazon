require 'rails_helper'

RSpec.describe IndexController, type: :controller do
	describe 'index page has all products' do 
		it "should load all the client's products" do 
			get :index
			expect(response).to render_template(:index)
		end
	end
end
