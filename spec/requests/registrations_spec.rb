require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  include ActiveJob::TestHelper

  let(:sign_up) { { name: 'Nina', email: 'nina@example.com', password: 'secret1', password_confirmation: 'secret1' } }
  let(:deliveries) { ActionMailer::Base.deliveries }

  before { Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: 'https://example.com/ipa.png') }

  def sign_in_as_nina
    post '/users/sign_in', params: { user: { email: 'nina@example.com', password: 'secret1' } }
  end

  it 'creates an unconfirmed customer and emails a confirmation link' do
    expect { perform_enqueued_jobs { post '/users', params: { user: sign_up } } }.to change { deliveries.size }.by(1)

    expect(User.find_by(email: 'nina@example.com')).to have_attributes(name: 'Nina', role: nil, confirmed_at: nil)
    expect(deliveries.last).to have_attributes(to: ['nina@example.com'], from: ['crabazon@toddseller.com'], subject: 'Welcome to Crabazon')
    expect(response).to redirect_to('/users/sign_up/sent')
    follow_redirect!
    expect(response.body).to include('<strong>nina@example.com</strong>')
    expect(response.body).not_to include('Signed in as Nina')
  end

  it 'confirms the address through the emailed link, then signs in' do
    perform_enqueued_jobs { post '/users', params: { user: sign_up } }
    link = CGI.unescapeHTML(deliveries.last.body.encoded[/href="([^"]*confirmation_token=[^"]*)"/, 1])

    get link
    expect(response).to redirect_to('/users/sign_in')
    follow_redirect!
    expect(response.body).to include('Your email address has been successfully confirmed.')

    sign_in_as_nina
    expect(response).to redirect_to('/index')
    follow_redirect!
    expect(response.body).to include('Signed in as Nina', 'Stone IPA')
  end

  it 'sends a new confirmation link from the resend page' do
    post '/users', params: { user: sign_up }
    get '/users/confirmation/new'
    expect(response).to have_http_status(:ok)

    expect { perform_enqueued_jobs { post '/users/confirmation', params: { user: { email: 'nina@example.com' } } } }.to change { deliveries.size }.by(1)
    expect(deliveries.last.subject).to eq('Welcome to Crabazon')
  end

  it 'refuses to sign in before the address is confirmed' do
    post '/users', params: { user: sign_up }

    sign_in_as_nina
    expect(response).to redirect_to('/users/sign_in')
    follow_redirect!
    expect(response.body).to include('You have to confirm your email address before continuing.')
  end

  describe 'with an email already in use' do
    before { User.create!(name: 'Old Nina', email: 'nina@example.com', password: 'secret1', confirmed_at: Time.current) }

    it 'answers like a new sign-up and tells the owner instead' do
      expect { perform_enqueued_jobs { post '/users', params: { user: sign_up } } }.to change { deliveries.size }.by(1)

      expect(User.count).to eq(1)
      expect(deliveries.last).to have_attributes(to: ['nina@example.com'], subject: 'Someone tried to sign up with your Crabazon address')
      expect(response).to redirect_to('/users/sign_up/sent')
      follow_redirect!
      expect(response.body).to include('<strong>nina@example.com</strong>')
    end

    it 'shows only the other mistakes' do
      expect { perform_enqueued_jobs { post '/users', params: { user: sign_up.merge(password_confirmation: 'other1') } } }.not_to change { [User.count, deliveries.size] }

      expect(CGI.unescapeHTML(response.body)).to include("Password confirmation doesn't match Password")
      expect(response.body).not_to include('already been taken')
    end
  end

  it 'sends the confirmation again when the address has an unconfirmed account' do
    post '/users', params: { user: sign_up }

    expect { perform_enqueued_jobs { post '/users', params: { user: sign_up } } }.to change { deliveries.size }.by(1)
    expect(User.count).to eq(1)
    expect(deliveries.last).to have_attributes(to: ['nina@example.com'], subject: 'Welcome to Crabazon')
    expect(response).to redirect_to('/users/sign_up/sent')
  end

  it 'refuses a confirmation that does not match' do
    expect { post '/users', params: { user: sign_up.merge(password_confirmation: 'other1') } }.not_to change { [User.count, deliveries.size] }
    expect(CGI.unescapeHTML(response.body)).to include("Password confirmation doesn't match Password")
  end

  it 'never grants the admin role' do
    post '/users', params: { user: sign_up.merge(role: 'admin') }

    nina = User.find_by(email: 'nina@example.com')
    expect(nina.role).to be_nil
    nina.confirm
    sign_in_as_nina
    get '/admin'
    expect(response).to redirect_to('/index')
  end
end
