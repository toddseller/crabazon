require 'rails_helper'

RSpec.describe 'Forgery protection', type: :request do
  # test.rb turns protection off for the rest of the suite.
  around do |example|
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  it 'refuses a sign-in without a token' do
    User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1', confirmed_at: Time.current)

    expect { post '/users/sign_in', params: { user: { email: 'cara@example.com', password: 'secret1' } } }
      .to raise_error(ActionController::InvalidAuthenticityToken)
    get '/orders'
    expect(response).to redirect_to('/users/sign_in')
  end

  it 'puts a token in the checkout form, for a submit without JavaScript' do
    sign_in User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1', confirmed_at: Time.current)

    get '/orders/new'

    expect(Nokogiri::HTML(response.body).at('form[action="/orders"] input[name="authenticity_token"]')).not_to be_nil
  end
end
