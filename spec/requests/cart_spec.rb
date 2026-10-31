require 'rails_helper'

RSpec.describe 'Cart', type: :request do
  let!(:ipa) { Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: 'https://example.com/ipa.png') }

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

  # as stored in the cookie: the total is a BigDecimal right after a request and a string once read back
  def cart_state
    JSON.parse([session[:cart], session[:cart_total]].to_json)
  end

  def expect_refused
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body['error']).to be_present
    expect(flash[:alert]).to be_present
  end

  it 'refuses to update to a quantity that is not 1 to the stock' do
    post "/carts/#{ipa.id}", xhr: true
    cart = cart_state

    ['0', '-3', 'abc', '6'].each do |quantity|
      post '/carts', params: { id: ipa.id, product_quantities: quantity }, xhr: true

      expect_refused
      expect(cart_state).to eq(cart), "quantity #{quantity}"
    end
  end

  it 'refuses to add past the stock' do
    5.times { post "/carts/#{ipa.id}", xhr: true }
    cart = cart_state

    post "/carts/#{ipa.id}", xhr: true

    expect_refused
    expect(cart_state).to eq(cart)
  end
end
