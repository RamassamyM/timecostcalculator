class ApplicationMailer < ActionMailer::Base
  default from: 'timeandcostcalculator@gmail.com', reply_to: 'adriano.montecalvo@ardo.com'
  layout 'mailer'
end
