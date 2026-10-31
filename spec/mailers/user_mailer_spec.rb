require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  it 'keeps a product image URL inside its src attribute' do
    url = 'https://example.com/a.png" onerror="x'
    user = User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1')
    product = Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: url)
    order = Order.create!(user: user, total: 4.5, order_date: Time.current)
    OrdersProduct.create!(order: order, product: product, quantity: 1)

    img = Nokogiri::HTML(UserMailer.order_email(order, user).body.encoded).at('img[alt="Product Image"]')

    expect(img['src']).to eq(url)
    expect(img['onerror']).to be_nil
  end
end
