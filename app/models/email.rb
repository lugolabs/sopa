class Email < ApplicationRecord
  validates :recipient, :subject, :body, presence: true

  after_create :send_email

  private

  def send_email
    address = Emailer::Address.new(recipient)
    message = Emailer::Message.new(address, subject, body, campaign_id)
    message.deliver
  end
end
