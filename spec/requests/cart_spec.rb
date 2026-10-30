require 'rails_helper'

RSpec.describe 'Cart', type: :request do
  let!(:ipa) { Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5) }

  it 'adds, counts, updates and removes a product' do
    post "/carts/#{ipa.id}", xhr: true
    expect(response.parsed_body).to include(
      'cart' => [a_hash_including('name' => 'Stone IPA', 'cart_quantity' => 1)],
      'cart_total' => '4.5',
      'quantity_available' => 4
    )

    post "/carts/#{ipa.id}", xhr: true
    expect(response.parsed_body).to include(
      'cart' => [a_hash_including('cart_quantity' => 2)],
      'cart_total' => '9.0',
      'quantity_available' => 3
    )

    post '/carts', params: { id: ipa.id, product_quantities: 4 }, xhr: true
    expect(response.parsed_body['cart_total']).to eq('18.0')

    delete "/carts/#{ipa.id}", xhr: true
    expect(response.parsed_body).to eq('cart' => [], 'cart_total' => 0)
  end
end
