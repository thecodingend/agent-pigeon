# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    def new
      render inertia: "auth/confirmations/new"
    end

    def create
      self.resource = resource_class.send_confirmation_instructions(resource_params)

      if successfully_sent?(resource)
        redirect_to new_user_session_path
      else
        redirect_to new_user_confirmation_path, inertia: { errors: resource.errors.to_hash(true) }
      end
    end

    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])

      if resource.errors.empty?
        set_flash_message! :notice, :confirmed
        redirect_to after_confirmation_path_for(resource_name, resource)
      else
        redirect_to new_user_confirmation_path, inertia: { errors: resource.errors.to_hash(true) }
      end
    end
  end
end
