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
  describe 'POST #create' do 
    let(:product) {Product.create!(name: Faker::Beer.name, description: Faker::Hipster.sentence, price: Faker::Commerce.price, quantity: Faker::Number.between(1,20), product_image: Faker::Avatar.image, reseller_id: 1 ) }
    it 'assigns the requested product to @product' do 
      get :edit, id: product.id
      expect(assigns(:product)).to eq product
    end

    it 'renders adds a new product to the list of products' do 
      get :edit, id: product.id
      expect(Product.all).to include(product)
    end
  end
  describe 'GET #edit' do 
    let(:product) {Product.create!(name: Faker::Beer.name, description: Faker::Hipster.sentence, price: Faker::Commerce.price, quantity: Faker::Number.between(1,20), product_image: Faker::Avatar.image, reseller_id: 1 ) }
    it 'assigns the requested product to @product' do 
      get :edit, id: product.id
      expect(assigns(:product)).to eq product
    end

    it 'renders the :edit template' do 
      get :edit, id: product.id
      expect(response).to render_template :edit
    end
  end
  describe 'PUT #update' do 
    let(:product) {Product.create!(name: "pie beer", description: Faker::Hipster.sentence, price: Faker::Commerce.price, quantity: Faker::Number.between(1,20), product_image: Faker::Avatar.image, reseller_id: 1) }
    it "changes @product's attributes" do
    	product.update_attributes(name: "billy bob beer")
    	expect(product.name).to eq("billy bob beer")
    end
  end
end