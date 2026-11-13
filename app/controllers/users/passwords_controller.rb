module Users
  class PasswordsController < Devise::PasswordsController
    rate_limit to: 5, within: 10.minutes, only: :create, name: "password-reset", store: AUTH_RATE_LIMIT_STORE,
      with: -> { head :too_many_requests }
  end
end
