require 'rails_helper'

RSpec.describe 'Storefront', type: :request do
  let!(:stouts) { Category.create!(name: 'Stouts') }
  let!(:pricey) { Product.create!(name: 'Imperial Stout', description: 'Dark', price: 12.5, quantity: 3, product_image: 'https://example.com/stout.png', categories: [stouts]) }
  let!(:cheap) { Product.create!(name: 'Session Lager', description: 'Light', price: 2.25, quantity: 7, product_image: 'https://example.com/lager.png') }

  it 'lists every product on the home page, cheapest first' do
    get '/'

    expect(response).to have_http_status(:ok)
    expect(response.body.index('Session Lager')).to be < response.body.index('Imperial Stout')
  end

  it 'shows only its own products on a category page' do
    get "/categories/#{stouts.id}"

    expect(response.body).to include('Welcome to Stouts!', 'Imperial Stout')
    expect(response.body).not_to include('Session Lager')
  end

  it 'shows a product on its page' do
    get "/products/#{pricey.id}"

    expect(response.body).to include('Imperial Stout', 'Dark', '12.50', 'Qty: 4', "/categories/#{stouts.id}")
  end
end
