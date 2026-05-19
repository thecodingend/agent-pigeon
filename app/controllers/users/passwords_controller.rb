# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    def new
      render inertia: "auth/passwords/new"
    end

    def edit
      render inertia: "auth/passwords/edit", props: {
        reset_password_token: params[:reset_password_token]
      }
    end

    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)

      if successfully_sent?(resource)
        redirect_to new_user_session_path
      else
        redirect_to new_user_password_path, inertia: { errors: resource.errors.to_hash(true) }
      end
    end

    def update
      self.resource = resource_class.reset_password_by_token(resource_params)

      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)

        if Devise.sign_in_after_reset_password
          set_flash_message! :notice, resource.active_for_authentication? ? :updated : :updated_not_active
          sign_in(resource_name, resource)
        else
          set_flash_message! :notice, :updated_not_active
        end

        redirect_to after_resetting_password_path_for(resource)
      else
        set_minimum_password_length
        redirect_to edit_user_password_path(reset_password_token: resource_params[:reset_password_token]),
          inertia: { errors: resource.errors.to_hash(true) }
      end
    end
  end
end
