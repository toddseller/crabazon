require 'rails_helper'

RSpec.describe 'Devise secret key' do
	it 'is the app secret_key_base, so no Devise key lives in the repo' do
		expect(Devise.secret_key).to eq(Rails.application.secret_key_base)
	end
end
