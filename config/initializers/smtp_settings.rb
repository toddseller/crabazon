ActionMailer::Base.smtp_settings = {
    address:              ENV['MAIL_HOST'],
    port:                 ENV['PORT'],
    user_name:            ENV['EMAIL_ADDRESS'],
    password:             ENV['EMAIL_SECRET'],
    authentication:       :login,
    tls:                  true,
    openssl_verify_mode:  'none'
  }