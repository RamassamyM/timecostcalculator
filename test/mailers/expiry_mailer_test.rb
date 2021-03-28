require 'test_helper'

class ExpiryMailerTest < ActionMailer::TestCase
  test "alert" do
    mail = ExpiryMailer.alert(row: { "Carrier"=>"MSC",
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
    assert_equal "Alert", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["no-reply@ardo.com"], mail.from
    # assert_match "Hi", mail.body.encoded
  end

end
