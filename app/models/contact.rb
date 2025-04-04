class Contact < ApplicationRecord
  validates :name, presence: true
  validates :message, presence: true
  validates :email, presence: true
  validates :subject, presence: true
end
