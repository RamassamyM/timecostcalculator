# Preview all emails at http://localhost:3000/rails/mailers/expiry_mailer
class ExpiryMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/expiry_mailer/alert
  def alert
    ExpiryMailer.alert({ "Carrier"=>"MSC",
      "Country of Origin"=>"Belgium",
      "Country of Destination"=>"USA",
      "Port of Loading"=>"Antwerp",
      "Port of Destination"=>"SEATTLE",
      "Container Type"=>"40 ft reefer",
      "Transit Time"=>"35",
      "Cost"=>"3975",
      "Currency"=>"USD",
      "Expiry"=>"30/06/21",
      "Notes"=>nil })
  end

end
