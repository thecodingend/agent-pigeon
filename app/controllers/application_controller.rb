class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  inertia_share auth: -> { { user: current_user&.as_json(only: [ :id, :email, :role ]) } }
  inertia_share csrf_token: -> { form_authenticity_token }
  inertia_share flash: -> { { notice: flash.notice, alert: flash.alert } }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    redirect_back_or_to root_path, alert: "You are not authorized to do that."
  end
end
