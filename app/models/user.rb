class User < ApplicationRecord
  devise :database_authenticatable, :argon2, :recoverable, :rememberable,
    :validatable, :timeoutable, :lockable, :omniauthable,
    omniauth_providers: [
      (ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present? ? :google_oauth2 : nil),
      (ENV["FACEBOOK_APP_ID"].present? && ENV["FACEBOOK_APP_SECRET"].present? ? :facebook : nil)
    ].compact
  has_many :articles, dependent: :restrict_with_error
end
