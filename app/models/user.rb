require "validator/email_validator"

class User < ApplicationRecord
  # top
  # バリデーション前に実施
  before_validation :downcase_email

  # bcrypt
  has_secure_password

  validates :name, presence: true,
                   length: {
                     maximum: 30,
                     allow_blank: true
                   }
  validates :email, presence: true,
                    email: {
                      allow_blank: true
                    }
  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
  validates :password, presence: true,
                       length: {
                         minimum: 8,
                         allow_blank: true
                        },
                       format: {
                         with: VALID_PASSWORD_REGEX,
                         message: :invalid_password,
                         allow_blank: true
                       },
                       allow_nil: true
  class << self
    def find_activated(email)
      find_by(email: email, activated: true)
    end
  end

  def email_activated?
    users = User.where.not(id: id)
    users.find_activated(email).present?
  end

  private
    # email小文字化
    def downcase_email
      self.email.downcase! if email
    end
end
