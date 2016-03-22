require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  describe 'GET #new' do 
    it 'assigns a new product to @product' do 
      get :new
      expect(assigns(:product)).to be_a_new(Product)
    end

    it 'renders the :new template' do 
      get :new
      expect(response).to render_template :new
    end
  end
  describe 'GET #edit' do 
    it 'assigns the requested product to @product' do 
      product = create(:product)
      get :edit, id: product
      expect(assigns(:contact)).to eq contact
    end

    it 'renders the :edit template' do 
      product = create(:product)
      get :edit, id: product
      expect(response).to render_template :edit
    end
  end
end