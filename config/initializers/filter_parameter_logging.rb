# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]

# Devise's mail jobs carry the raw reset token as an argument, and Active Job logs arguments.
ActionMailer::MailDeliveryJob.log_arguments = false
