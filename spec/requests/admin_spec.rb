require 'rails_helper'

RSpec.describe 'Admin', type: :request do
  let!(:stouts) { Category.create!(name: 'Stouts') }
  let!(:ipa) { Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: 'https://example.com/ipa.png') }
  let(:product_params) { { name: 'Imperial Stout', description: 'Dark', price: 12.5, quantity: 3, product_image: 'https://example.com/stout.png' } }

  before { sign_in User.create!(name: 'Ada', email: 'ada@example.com', password: 'secret1', role: 'admin') }

  it 'lists the products on /admin' do
    get '/admin'

    expect(response.body).to include('Your Inventory!', 'Stone IPA')
  end

  it 'creates, updates and deletes a product' do
    post '/products', params: { product: product_params, category_ids: [stouts.id] }
    expect(response).to redirect_to('/admin')
    stout = Product.find_by!(name: 'Imperial Stout')
    expect(stout.categories).to eq([stouts])

    patch "/products/#{stout.id}", params: { product: product_params.merge(quantity: 9), category_ids: [stouts.id] }
    expect(response).to redirect_to('/admin')
    expect(stout.reload.quantity).to eq(9)

    delete "/products/#{stout.id}"
    expect(response).to redirect_to('/admin')
    expect(Product.exists?(stout.id)).to be(false)
  end

  it 'creates and renames a category' do
    post '/categories', params: { category: { name: 'Lagers' } }
    lagers = Category.find_by!(name: 'Lagers')

    patch "/categories/#{lagers.id}", params: { category: { name: 'Pilsners' } }

    expect(response).to redirect_to('/index')
    expect(lagers.reload.name).to eq('Pilsners')
  end
end
