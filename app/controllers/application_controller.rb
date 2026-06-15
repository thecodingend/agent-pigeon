class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  inertia_share auth: -> { { user: current_user && { id: current_user.id, email: current_user.email, role: current_user.role } } }
  inertia_share csrf_token: -> { form_authenticity_token }
  inertia_share flash: -> { { notice: flash.notice, alert: flash.alert } }
  inertia_share nav: lambda {
    next nil unless current_user
    connection = current_user.email_connection
    {
      email_connection_complete: connection&.complete? || false,
      support_address: connection&.support_address
    }
  }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def after_sign_in_path_for(_resource)
    authenticated_root_path
  end

  private

  def user_not_authorized
    redirect_back_or_to root_path, alert: "You are not authorized to do that."
  end
end
