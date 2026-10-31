require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  let!(:cara) { User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1') }
  let!(:ipa) { Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: 'https://example.com/ipa.png') }
  let!(:lager) { Product.create!(name: 'Session Lager', description: 'Light', price: 2.25, quantity: 7, product_image: 'https://example.com/lager.png') }

  before { sign_in cara }

  it 'checks out the cart' do
    2.times { post "/carts/#{ipa.id}", xhr: true }
    post "/carts/#{lager.id}", xhr: true
    ipa.update!(price: 5)

    post '/orders'

    expect(Order.count).to eq(1)
    order = Order.last
    expect(order).to have_attributes(user_id: cara.id, total: 12.25)
    expect(order.orders_product.pluck(:product_id, :quantity)).to contain_exactly([ipa.id, 2], [lager.id, 1])
    expect([ipa.reload.quantity, lager.reload.quantity]).to eq([3, 6])
    expect(ActionMailer::Base.deliveries.map(&:to)).to eq([['cara@example.com']])
    expect(ActionMailer::Base.deliveries.last.from).to eq(['crabazon@toddseller.com'])
    expect(session[:cart]).to eq({})
    expect(response).to redirect_to("/orders/#{order.id}")
  end

  it 'refuses a cart holding more than is now in stock' do
    2.times { post "/carts/#{ipa.id}", xhr: true }
    ipa.update!(quantity: 1)

    expect { post '/orders' }.not_to change { [Order.count, OrdersProduct.count, ActionMailer::Base.deliveries.size] }

    expect(ipa.reload.quantity).to eq(1)
    expect(session[:cart]).to eq(ipa.id.to_s => 2)
    expect(flash[:alert]).to include('Stone IPA')
    expect(response).to redirect_to('/orders/new')
  end

  it 'refuses an empty cart' do
    post "/carts/#{ipa.id}", xhr: true
    delete "/carts/#{ipa.id}", xhr: true

    expect { post '/orders' }.not_to change { [Order.count, ActionMailer::Base.deliveries.size] }

    expect(response).to redirect_to('/orders/new')
  end

  it 'still places the order when the confirmation email fails' do
    post "/carts/#{ipa.id}", xhr: true
    failing_mail = double
    allow(failing_mail).to receive(:deliver_now).and_raise(Net::SMTPAuthenticationError, 'smtp down')
    allow(UserMailer).to receive(:order_email).and_return(failing_mail)

    post '/orders'

    expect(Order.count).to eq(1)
    expect(session[:cart]).to eq({})
    expect(response).to redirect_to("/orders/#{Order.last.id}")
  end

  it "lists only the customer's own orders" do
    mine = Order.create!(user: cara, total: 9, order_date: Time.now)
    other = User.create!(name: 'Otto', email: 'otto@example.com', password: 'secret1')
    theirs = Order.create!(user: other, total: 4.5, order_date: Time.now)

    get '/orders'

    expect(response.body).to include("Order Number #{mine.id}")
    expect(response.body).not_to include("Order Number #{theirs.id}")
  end

  it 'shows the customer their own order' do
    mine = Order.create!(user: cara, total: 9, order_date: Time.now)
    OrdersProduct.create!(order: mine, product: ipa, quantity: 2)

    get "/orders/#{mine.id}"

    expect(response.body).to include('Stone IPA', '$9.00')
  end

  it "keeps another customer's order hidden" do
    porter = Product.create!(name: 'Secret Porter', description: 'Dark', price: 6, quantity: 3, product_image: 'https://example.com/porter.png')
    theirs = Order.create!(user: User.create!(name: 'Otto', email: 'otto@example.com', password: 'secret1'), total: 6, order_date: Time.now)
    OrdersProduct.create!(order: theirs, product: porter, quantity: 1)

    get "/orders/#{theirs.id}"

    expect(response).to redirect_to('/orders')
    expect(flash[:alert]).to eq('Order not found.')
    expect(response.body).not_to include('Secret Porter')
  end

  it 'answers a missing order the same way' do
    get '/orders/999999'

    expect(response).to redirect_to('/orders')
    expect(flash[:alert]).to eq('Order not found.')
  end
end

RSpec.describe 'Checkout without signing in', type: :request do
  it 'sends the visitor to sign in and changes nothing' do
    ipa = Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: 'https://example.com/ipa.png')
    post "/carts/#{ipa.id}", xhr: true

    expect { post '/orders' }.not_to change { [Order.count, ipa.reload.quantity] }
    expect(response).to redirect_to('/users/sign_in')
  end
end
