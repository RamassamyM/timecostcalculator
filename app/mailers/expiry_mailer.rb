class ExpiryMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.expiry_mailer.alert.subject
  #
  def alert(data:, email_to:)
    @ocean_shipment = data
    mail to: email_to, subject: 'Ocean freight entry is expiring in 10 days'
  end
end
