# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      user = User.from_google(request.env.fetch("omniauth.auth"))

      set_flash_message! :notice, :success, kind: "Google"
      sign_in_and_redirect user, event: :authentication
    end

    def failure
      redirect_to new_user_session_path, alert: "Could not sign in with Google."
    end
  end
end
