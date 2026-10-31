require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  let(:sign_up) { { name: 'Nina', email: 'nina@example.com', password: 'secret1', password_confirmation: 'secret1' } }
  let(:deliveries) { ActionMailer::Base.deliveries }

  before { Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: 'https://example.com/ipa.png') }

  it 'creates a signed-in customer with an empty cart and sends the welcome email' do
    expect { post '/users', params: { user: sign_up } }.to change { deliveries.size }.by(1)

    expect(User.find_by(email: 'nina@example.com')).to have_attributes(name: 'Nina', role: nil)
    expect(deliveries.last).to have_attributes(to: ['nina@example.com'], from: ['crabazon@toddseller.com'], subject: 'Welcome to Crabazon')
    expect(response).to redirect_to('/index')

    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Signed in as Nina', 'Stone IPA')
  end

  it 'refuses an email already in use' do
    User.create!(name: 'Old Nina', email: 'nina@example.com', password: 'secret1')

    expect { post '/users', params: { user: sign_up } }.not_to change { [User.count, deliveries.size] }
    expect(response.body).to include('Email has already been taken')
  end

  it 'refuses a confirmation that does not match' do
    expect { post '/users', params: { user: sign_up.merge(password_confirmation: 'other1') } }.not_to change { [User.count, deliveries.size] }
    expect(CGI.unescapeHTML(response.body)).to include("Password confirmation doesn't match Password")
  end

  it 'never grants the admin role' do
    post '/users', params: { user: sign_up.merge(role: 'admin') }

    expect(User.find_by(email: 'nina@example.com').role).to be_nil
    get '/admin'
    expect(response).to redirect_to('/index')
  end
end
