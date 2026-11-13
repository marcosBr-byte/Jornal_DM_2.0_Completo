class User < ApplicationRecord
  devise :database_authenticatable, :argon2, :recoverable, :rememberable,
    :validatable, :timeoutable, :lockable, :omniauthable,
    omniauth_providers: [
      (ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present? ? :google_oauth2 : nil),
      (ENV["FACEBOOK_APP_ID"].present? && ENV["FACEBOOK_APP_SECRET"].present? ? :facebook : nil)
    ].compact
  has_many :articles, dependent: :restrict_with_error
  validates :password, length: { minimum: :minimum_password_length }, allow_blank: true

  def minimum_password_length
    Rails.env.production? ? 12 : 6
  end

  # A database copied from development must not allow its short demo password
  # to authenticate on the public production server.
  def valid_password?(password)
    return false if password.to_s.length < minimum_password_length
    super
  end
end
