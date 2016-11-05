class Email < ApplicationRecord
  validates :recipient, :subject, :body, presence: true

  after_create :send_email

  Emailer.configure do |config|
    config.api_key = ENV['MAILGUN_API_KEY']
    config.domain  = ENV['MAILGUN_DOMAIN']
  end

  private

  def send_email
    address = Emailer::Address.new(recipient)
    message = Emailer::Message.new(address, subject, body, campaign_id)
    message.deliver
  end
end
