require 'rails_helper'

RSpec.describe 'Password reset', type: :request do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:deliveries) { ActionMailer::Base.deliveries }

  def sign_in_as(password)
    post '/users/sign_in', params: { user: { email: 'cara@example.com', password: password } }
  end

  it 'emails a link that sets a new password' do
    User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1')
    Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: 'https://example.com/ipa.png')

    get '/users/password/new'
    expect(response).to have_http_status(:ok)

    expect { perform_enqueued_jobs { post '/users/password', params: { user: { email: 'cara@example.com' } } } }.to change { deliveries.size }.by(1)
    expect(deliveries.last).to have_attributes(to: ['cara@example.com'], from: ['crabazon@toddseller.com'])
    expect(response).to redirect_to('/users/password/sent')
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('If an account uses <strong>cara@example.com</strong>')
    expect(response.body).not_to include('You will receive an email', 'If your email address exists')

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

  it 'answers an unknown email exactly like a known one' do
    expect { perform_enqueued_jobs { post '/users/password', params: { user: { email: 'nobody@example.com' } } } }.not_to change { deliveries.size }
    expect(response).to redirect_to('/users/password/sent')
    follow_redirect!
    expect(response.body).to include('If an account uses <strong>nobody@example.com</strong>')
  end

  # Sending during the request would make a known address answer more slowly than an unknown one.
  it 'sends the reset email after answering' do
    User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1')

    expect { post '/users/password', params: { user: { email: 'cara@example.com' } } }.not_to change { deliveries.size }
    expect(enqueued_jobs.size).to eq(1)
  end

  it 'keeps the reset token out of the log' do
    User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1')
    log = StringIO.new
    original = ActiveJob::Base.logger
    ActiveJob::Base.logger = ActiveSupport::Logger.new(log)

    perform_enqueued_jobs { post '/users/password', params: { user: { email: 'cara@example.com' } } }

    token = CGI.unescapeHTML(deliveries.last.body.encoded[/reset_password_token=([^"&]+)/, 1])
    expect(log.string).to include('MailDeliveryJob')
    expect(log.string).not_to include(token)
  ensure
    ActiveJob::Base.logger = original
  end

  it 'names no address when none was typed' do
    post '/users/password', params: { user: { email: '' } }
    follow_redirect!

    expect(response.body).to include('If an account uses <strong>your email address</strong>')
  end

  describe 'limit per address' do
    before do
      Users::PasswordsController::RESET_LIMIT_STORE.clear
      User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1')
      User.create!(name: 'Dan', email: 'dan@example.com', password: 'secret1')
    end

    def ask_for_reset(email)
      perform_enqueued_jobs { post '/users/password', params: { user: { email: email } } }
    end

    it 'turns away the sixth request for an address within an hour' do
      5.times { ask_for_reset('cara@example.com') }

      expect { ask_for_reset(' CARA@example.com ') }.not_to change { deliveries.size }
      expect(response).to redirect_to('/users/password/new')
      follow_redirect!
      expect(response.body).to include('Too many reset requests for that address. Try again in an hour.')

      expect { ask_for_reset('dan@example.com') }.to change { deliveries.size }.by(1)
    end

    it 'lets the address through again after an hour' do
      5.times { ask_for_reset('cara@example.com') }

      travel 61.minutes do
        expect { ask_for_reset('cara@example.com') }.to change { deliveries.size }.by(1)
      end
    end
  end
end
