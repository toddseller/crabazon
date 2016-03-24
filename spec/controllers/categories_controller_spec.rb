require 'rails_helper'

RSpec.describe ProductsController, type: :controller do

  describe 'GET #new' do 
    # it 'assigns a new category to @category' do 
    #   get :new
    #   expect(assigns(:category)).to be_a_new(Category)
    # end

    it 'renders the :new template' do 
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do 
    let(:category) {Category.create(name: 'test')}
    it 'assigns the requested category to @category' do 
      get :edit, id: category.id
      expect(assigns(:category)).to eq category
    end


  #   it 'renders adds a new product to the list of products' do 
  #     get :edit, id: product.id
  #     expect(Product.all).to include(product)
  #   end

  #   it "redirects to products#index" do
  #       post :create, product: {name: "pie beer", description: 'description', price: 'price', quantity: 'quantity', product_image: '', reseller_id: 1}
  #       expect(response).to redirect_to  admin_index_path
  #     end

  #   context "with invalid attributes" do
  #       it "does not save the new product in the database" do
  #         tests = Product.all
  #         expect{
  #           post :create, product: { name: 'bad test'}
  #           }.not_to change(tests, :count)
  #         end
  #         it "re-renders the :new template" do
  #           post :create, product: {name: 'bad test'}
  #           expect(response).to render_template :new
  #         end
  #       end
     end

  # describe 'GET #edit' do 
  #   let(:product) {Product.create!(name: Faker::Beer.name, description: Faker::Hipster.sentence, price: Faker::Commerce.price, quantity: Faker::Number.between(1,20), product_image: Faker::Avatar.image, reseller_id: 1 ) }
  #   it 'assigns the requested product to @product' do 
  #     get :edit, id: product.id
  #     expect(assigns(:product)).to eq product
  #   end

  #   it 'renders the :edit template' do 
  #     get :edit, id: product.id
  #     expect(response).to render_template :edit
  #   end
  # end

  # describe 'PUT #update' do 
  #   let(:product) {Product.create!(name: "pie beer", description: Faker::Hipster.sentence, price: Faker::Commerce.price, quantity: Faker::Number.between(1,20), product_image: Faker::Avatar.image, reseller_id: 1) }
  
  #   before :each do
  #     @product = Product.create(name: "pie beer", description: 'description', price: 'price', quantity: 'quantity', product_image: '', reseller_id: 1)
  #   end

  #   context "with valid attributes" do
  #     it "updates the product in the database" do
  #       patch :update, id: @product,
  #       product: { name: "billy bob beer"}
  #       @product.reload
  #       expect(@product.name).to eq('billy bob beer')
  #     end
  #     it "redirects to the product" do
  #       patch :update, id: @product,
  #       product: { name: 'test2'}
  #       expect(response).to redirect_to admin_index_path
  #     end
  #   end

  #   context "with invalid attributes" do
  #     it "does not update the product" do
  #       patch :update, id: @product,
  #       product: { name: nil}
  #       @product.reload
  #       expect(@product.name).not_to eq('bad test')
  #     end
  #     it "re-renders the :edit template" do
  #       patch :update, id: @product,
  #       product: { name: nil}
  #       expect(response).to render_template :edit
  #     end
  #   end

  # end

  #  describe 'DELETE #destroy' do
  #   before :each do
  #     @product = Product.create(name: "pie beer", description: 'description', price: 'price', quantity: 'quantity', product_image: '', reseller_id: 1)
  #   end
  #   it "deletes the product from the database" do
  #     tests = Product.all
  #     expect{
  #       delete :destroy, id: @product
  #       }.to change(tests,:count).by(-1)
  #   end
  #     it "redirects to users#index" do
  #       delete :destroy, id: @product
  #       expect(response).to redirect_to admin_index_path
  #     end
  # end


end