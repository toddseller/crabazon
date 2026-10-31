require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  def sign_in_as(email, password)
    post '/users/sign_in', params: { user: { email: email, password: password } }
  end

  it 'lands a customer on the index page' do
    User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1', confirmed_at: Time.current)

    sign_in_as('cara@example.com', 'secret1')

    expect(response).to redirect_to('/index')
  end

  it 'lands an admin on /admin' do
    User.create!(name: 'Ada', email: 'ada@example.com', password: 'secret1', role: 'admin', confirmed_at: Time.current)

    sign_in_as('ada@example.com', 'secret1')

    expect(response).to redirect_to('/admin')
  end

  it 'refuses a wrong password' do
    User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1', confirmed_at: Time.current)

    sign_in_as('cara@example.com', 'wrong-password')

    expect(response.body).to include('Invalid email or password.')
    expect(session['warden.user.user.key']).to be_nil
  end
end
