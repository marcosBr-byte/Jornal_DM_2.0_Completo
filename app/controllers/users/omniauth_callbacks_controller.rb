module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      authenticate_provider
    end
    def facebook
      authenticate_provider
    end
    def failure
      redirect_to new_user_session_path, alert: "Não foi possível autenticar com o provedor."
    end
    private
    def authenticate_provider
      auth = request.env["omniauth.auth"]
      user = auth && User.find_by(provider: auth.provider, uid: auth.uid)
      if user&.admin? && user.active_for_authentication?
        sign_in_and_redirect user, event: :authentication
      else
        redirect_to new_user_session_path, alert: "Conta externa não autorizada. Solicite a vinculação à administração."
      end
    end
  end
end
