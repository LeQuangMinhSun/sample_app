class User < ApplicationRecord
  USER_PARAMS = %i(name email password password_confirmation).freeze
  VALID_EMAIL_REGEX = Regexp.new Settings.email.valid_regex

  before_save :downcase_email

  validates :name, presence: true, length: {maximum: Settings.name.max_length}
  validates :email, presence: true,
            length: {maximum: Settings.email.max_length},
            format: {with: VALID_EMAIL_REGEX}, uniqueness: true

  has_secure_password

  private

  def downcase_email
    email.downcase!
  end
end
