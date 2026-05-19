# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def new
      render inertia: "auth/sign_in"
    end
  end
end
