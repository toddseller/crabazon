require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  let!(:cara) { User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1') }
  let!(:ipa) { Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: 'https://example.com/ipa.png') }
  let!(:lager) { Product.create!(name: 'Session Lager', description: 'Light', price: 2.25, quantity: 7, product_image: 'https://example.com/lager.png') }

  before { sign_in cara }

  it 'checks out the cart' do
    2.times { post "/carts/#{ipa.id}", xhr: true }
    post "/carts/#{lager.id}", xhr: true

    post '/orders'

    expect(Order.count).to eq(1)
    order = Order.last
    expect(order).to have_attributes(user_id: cara.id, total: 11.25)
    expect(order.orders_product.pluck(:product_id, :quantity)).to contain_exactly([ipa.id, 2], [lager.id, 1])
    expect([ipa.reload.quantity, lager.reload.quantity]).to eq([3, 6])
    expect(ActionMailer::Base.deliveries.map(&:to)).to eq([['cara@example.com']])
    expect(session[:cart]).to eq({})
    expect(response).to redirect_to("/orders/#{order.id}")
  end

  it "lists only the customer's own orders" do
    mine = Order.create!(user: cara, total: 9, order_date: Time.now)
    other = User.create!(name: 'Otto', email: 'otto@example.com', password: 'secret1')
    theirs = Order.create!(user: other, total: 4.5, order_date: Time.now)

    get '/orders'

    expect(response.body).to include("Order Number #{mine.id}")
    expect(response.body).not_to include("Order Number #{theirs.id}")
  end
end
