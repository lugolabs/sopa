class Email < ApplicationRecord
  validates :recipient, :subject, :body, presence: true
end
