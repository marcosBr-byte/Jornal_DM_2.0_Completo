module Users
  class SessionsController < Devise::SessionsController
    rate_limit to: 10, within: 3.minutes, only: :create, name: "sign-in", store: AUTH_RATE_LIMIT_STORE,
      with: -> { head :too_many_requests }
  end
end
