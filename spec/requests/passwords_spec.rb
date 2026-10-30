require 'rails_helper'

RSpec.describe 'Password reset', type: :request do
  let(:deliveries) { ActionMailer::Base.deliveries }

  def sign_in_as(password)
    post '/users/sign_in', params: { user: { email: 'cara@example.com', password: password } }
  end

  it 'emails a link that sets a new password' do
    User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1')
    Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5)

    get '/users/password/new'
    expect(response).to have_http_status(:ok)

    expect { post '/users/password', params: { user: { email: 'cara@example.com' } } }.to change { deliveries.size }.by(1)
    expect(deliveries.last).to have_attributes(to: ['cara@example.com'], from: ['crabazon@toddseller.com'])
    expect(response).to redirect_to('/users/password/sent')
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('cara@example.com')
    expect(response.body).not_to include('You will receive an email')

    link = CGI.unescapeHTML(deliveries.last.body.encoded[/href="([^"]+)"/, 1])
    expect(link).to start_with('http://www.example.com/users/password/edit?reset_password_token=')
    get link
    expect(response).to have_http_status(:ok)

    token = Rack::Utils.parse_query(URI(link).query)['reset_password_token']
    put '/users/password', params: { user: { reset_password_token: token, password: 'newpass1', password_confirmation: 'newpass1' } },
                           headers: { 'HTTP_REFERER' => link }
    expect(response).to redirect_to('/index')
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Signed in as Cara', 'Stone IPA')
    delete '/users/sign_out'

    sign_in_as('secret1')
    expect(session['warden.user.user.key']).to be_nil
    sign_in_as('newpass1')
    expect(response).to redirect_to('/index')
  end
end
