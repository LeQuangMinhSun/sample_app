class User < ApplicationRecord
  has_many :microposts, dependent: :destroy

  USER_PARAMS = %i(name email password password_confirmation).freeze
  PASSWORD_PARAMS = %i(password password_confirmation).freeze
  VALID_EMAIL_REGEX = Regexp.new Settings.email.valid_regex

  scope :name_asc, ->{order(name: :asc)}

  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: Settings.name.max_length}
  validates :email, presence: true,
            length: {maximum: Settings.email.max_length},
            format: {with: VALID_EMAIL_REGEX}, uniqueness: true
  validates :password,
            presence: true,
            length: {minimum: Settings.password.min_length},
            allow_nil: true

  has_secure_password

  def feed
    microposts
  end

  attr_accessor :remember_token, :activation_token, :reset_token

  def password_reset_expired?
    reset_sent_at < Settings.password.reset_expired.hours.ago
  end

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def forget
    update_column :remember_digest, nil
  end

  def authenticated? attribute, token
    digest = public_send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
