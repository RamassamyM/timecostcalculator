class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@ardo.com', reply_to: "adriano.montecalvo@ardo.com"
  layout 'mailer'
end
