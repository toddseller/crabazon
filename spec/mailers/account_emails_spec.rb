require 'rails_helper'

RSpec.describe 'Account emails' do
  let(:user) { User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1', confirmed_at: Time.current) }

  def page(mail) = Nokogiri::HTML(mail.html_part ? mail.html_part.body.decoded : mail.body.decoded)

  def button_href(mail) = page(mail).at('table[bgcolor="#e58c33"] a')&.[]('href')

  def expect_shop_design(mail, heading)
    expect(page(mail).at('img[src$="crabazon150x47.png"]')).not_to be_nil
    expect(page(mail).text.squish).to include(heading)
  end

  it 'sends the confirmation as the welcome email, with a confirm button' do
    mail = Devise::Mailer.confirmation_instructions(user, 'tok1')

    expect(mail.subject).to eq('Welcome to Crabazon')
    expect_shop_design(mail, 'Welcome to the family!')
    expect(button_href(mail)).to eq('http://www.example.com/users/confirmation?confirmation_token=tok1')
  end

  it 'sends the reset email with a change-password button' do
    mail = Devise::Mailer.reset_password_instructions(user, 'tok2')

    expect(mail.subject).to eq('Reset your Crabazon password')
    expect_shop_design(mail, 'Reset your password')
    expect(button_href(mail)).to eq('http://www.example.com/users/password/edit?reset_password_token=tok2')
  end

  it 'tells the owner of a taken address, with sign-in and reset links' do
    mail = UserMailer.sign_up_attempt(user)

    expect(mail.subject).to eq('Someone tried to sign up with your Crabazon address')
    expect_shop_design(mail, 'Someone tried to sign up with your address')
    expect(button_href(mail)).to eq('http://www.example.com/users/sign_in')
    expect(page(mail).at('a[href="http://www.example.com/users/password/new"]')).not_to be_nil
  end
end
